function [wweights] = getweightPeru(bmsk,mask)

bmsk.peru(~isnan(bmsk.peru))=1;
bmsk.peru = repmat(bmsk.peru,1,1,12);
tmpmask=bmsk.peru(:,:,1);
tmpmask(isnan(tmpmask))=0;
tmpmask=tmpmask.*mask(:,:,1);
tmpmasktop=zeros(size(tmpmask)).*mask(:,:,1);
tmpmasktop(:,1:719)=tmpmasktop(:,1:719)+tmpmask(:,2:720);
tmpmasktop(:,1:719)=tmpmasktop(:,1:719)+tmpmasktop(:,2:720);
tmpmasktop(:,1:719)=tmpmasktop(:,1:719)+tmpmasktop(:,2:720);
tmpmasktop(:,1:719)=tmpmasktop(:,1:719)+tmpmasktop(:,2:720);
tmpmasktop(:,1:719)=tmpmasktop(:,1:719)+tmpmasktop(:,2:720);
tmpmasktop(:,1:719)=tmpmasktop(:,1:719)+tmpmasktop(:,2:720);
tmpmasktop=tmpmasktop.*bmsk.peru(:,:,1);
%pcolor(tmpmasktop');shading flat; colorbar;xlim([250, 410]);ylim([250, 400]);

tmpmaskbot=zeros(size(tmpmask)).*mask(:,:,1);
tmpmaskbot(:,2:720)=tmpmaskbot(:,2:720)+tmpmask(:,1:719);
tmpmaskbot(:,2:720)=tmpmaskbot(:,2:720)+tmpmaskbot(:,1:719);
tmpmaskbot(:,2:720)=tmpmaskbot(:,2:720)+tmpmaskbot(:,1:719);
tmpmaskbot(:,2:720)=tmpmaskbot(:,2:720)+tmpmaskbot(:,1:719);
tmpmaskbot(:,2:720)=tmpmaskbot(:,2:720)+tmpmaskbot(:,1:719);
tmpmaskbot(:,2:720)=tmpmaskbot(:,2:720)+tmpmaskbot(:,1:719);
tmpmaskbot=tmpmaskbot.*bmsk.peru(:,:,1);
%pcolor(tmpmaskbot');shading flat; colorbar;xlim([250, 410]);ylim([250, 400]);

tmpmaskright=zeros(size(tmpmask)).*mask(:,:,1);
tmpmaskright(2:1440,:)=tmpmaskright(2:1440,:)+tmpmask(1:1439,:);
tmpmaskright(2:1440,:)=tmpmaskright(2:1440,:)+tmpmaskright(1:1439,:);
tmpmaskright(2:1440,:)=tmpmaskright(2:1440,:)+tmpmaskright(1:1439,:);
tmpmaskright(2:1440,:)=tmpmaskright(2:1440,:)+tmpmaskright(1:1439,:);
tmpmaskright(2:1440,:)=tmpmaskright(2:1440,:)+tmpmaskright(1:1439,:);
tmpmaskright(2:1440,:)=tmpmaskright(2:1440,:)+tmpmaskright(1:1439,:);
tmpmaskright=tmpmaskright.*bmsk.peru(:,:,1);
%pcolor(tmpmaskright');shading flat; colorbar;xlim([250, 410]);ylim([250, 400]);

maskpre = cat(3,tmpmasktop,tmpmaskbot,tmpmaskright);
maskpre = min(maskpre,[],3);
wweights.Peru = maskpre/nanmax(maskpre(:));
wweights.Peru(isnan(wweights.Peru))=0;wweights.Peru=wweights.Peru.*mask(:,:,1);
wweights.Global = 1-wweights.Peru;
%pcolor(weightsPeru');shading flat; colorbar;xlim([270, 460]);ylim([250, 400]);
