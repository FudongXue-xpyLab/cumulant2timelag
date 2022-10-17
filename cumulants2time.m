%% Image TIFF file or image sequence.
%
%stack='example.tif';
if ~exist('pathname','var')
    pathname = [cd, '\'];
end
[filename, pathname] = uigetfile( ...
    {'*.tif;*.tiff', 'All TIF-Files (*.tif,*.tiff)'; ...
        '*.*','All Files (*.*)'}, ...
    'Select Image File','MultiSelect', 'off', pathname);

stackname = fullfile(pathname, filename);
imgs = imreadstack(stackname);
frames = length(imgs(1,1,:));
avg=sum(imgs(:,:,:),3)/frames;
[s, ind]=sort(avg(:),'descend');
n=floor(length(ind)*0.01);
[cols,rows] = ind2sub(size(avg),ind(1:n));
delt = zeros(n,frames);
timelag = floor(frames/2);
cum = zeros(n+1,timelag);
cum(1,:) = 1:timelag;
imgs = imgs - repmat(avg, [1 1 frames]);
for indx = 1:n
    delt(indx,:) = imgs(cols(indx),rows(indx),:);
    for i = 1:timelag
        delt1 = delt(indx, 1:timelag );
        delt1(2,:) = delt(indx, i+(0:timelag-1));
        cum(indx+1,i) = mean(delt1(1,:).*delt1(2,:));
    end
    if indx == 1
        figure,loglog(cum(1,:),cum(2,:))
        hold on
    else
        loglog(cum(1,:),cum(indx+1,:))
    end
end
ylim([1 ceil(max(cum(:))+1)])
hold off
% log_cum = log10(cum);
% figure,plot(log_cum(1,:),log_cum(2,:))
% ylim([1 ceil(max(abs(log_cum(:)+1)))])
% if length(log_cum(:,1))>2
%     hold on
%     for plog = 2:n
%         plot(log_cum(1,:),log_cum(plog+1,:))
%     end
%     hold off
% end
% tao = log_cum(1,:);
% meanCulm = log10(mean(cum(2,:),1));
tao = cum(1,:);
meanCulm = mean(cum(2,:),1);
figure,loglog(tao,meanCulm,'-')
t = strfind(stackname,'.');
filebase = stackname(1:t(end)-1);
fidm = [filebase,'_cumulants.xlsx'];
xlswrite(fidm,cum','sheet1');
xlswrite(fidm,[tao',meanCulm'],'mean');
xlswrite(fidm,[rows,cols],'position');
