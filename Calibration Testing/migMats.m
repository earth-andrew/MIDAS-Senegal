clear all;

migData = readtable("ipumsi_00001.csv");

close all;

placeLabels = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", ...
    "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou", ...
    "Abroad", "NIU"};

ageClasses = [14 24 39 54 69 84 99];

[b,i,sex] = unique(migData.sex); %female is 1; male is 2
% [b_geo2,i,rec_geo2] = unique(migData.geo2_sn2013); %department living
[b_geo1,i,rec_geo1] = unique(migData.geo1_sn); %region living

% [b_send_geo2_1,i,mig1_geo2] = unique(migData.mig2_1_sn); %department living 1 year ago
[b_send_geo1_1,i,mig1_geo1] = unique(migData.mig1_1_sn); %region living 1 year ago
% [b_send_geo2_5,i,mig5_geo2] = unique(migData.mig2_5_sn); %department living 1 year ago
[b_send_geo1_5,i,mig5_geo1] = unique(migData.mig1_5_sn); %region living 1 year ago
% [b_send_geo2_10,i,mig10_geo2] = unique(migData.mig2_10_sn); %department living 1 year ago
[b_send_geo1_10,i,mig10_geo1] = unique(migData.mig1_10_sn); %region living 1 year ago

mig_1_region = zeros(10,8,2,size(ageClasses,2));
mig_5_region = zeros(10,8,2,size(ageClasses,2));
mig_10_region = zeros(10,8,2,size(ageClasses,2));
% 
% mig_1_dept = zeros(2,size(ageClasses,2),max(mig1_geo2),max(rec_geo2));
% mig_5_dept = zeros(2,size(ageClasses,2),max(mig5_geo2),max(rec_geo2));
% mig_10_dept = zeros(2,size(ageClasses,2),max(mig10_geo2),max(rec_geo2));

for indexI = 1:height(migData)
    mig_1_region(mig1_geo1(indexI),rec_geo1(indexI),sex(indexI),find(migData.age(indexI) < ageClasses,1)) = ...
        mig_1_region(mig1_geo1(indexI),rec_geo1(indexI),sex(indexI),find(migData.age(indexI) < ageClasses,1)) + 1;
    mig_5_region(mig5_geo1(indexI),rec_geo1(indexI),sex(indexI),find(migData.age(indexI) < ageClasses,1)) = ...
        mig_5_region(mig5_geo1(indexI),rec_geo1(indexI),sex(indexI),find(migData.age(indexI) < ageClasses,1)) + 1;
    mig_10_region(mig10_geo1(indexI),rec_geo1(indexI),sex(indexI),find(migData.age(indexI) < ageClasses,1)) = ...
        mig_10_region(mig10_geo1(indexI),rec_geo1(indexI),sex(indexI),find(migData.age(indexI) < ageClasses,1)) + 1;

%     mig_1_dept(sex(indexI),find(migData.age(indexI) < ageClasses,1),mig1_geo2(indexI),rec_geo2(indexI));
%     mig_5_dept(sex(indexI),find(migData.age(indexI) < ageClasses,1),mig5_geo2(indexI),rec_geo2(indexI));
%     mig_10_dept(sex(indexI),find(migData.age(indexI) < ageClasses,1),mig10_geo2(indexI),rec_geo2(indexI));
end

popData = sum(mig_1_region,2:4);

mig_1_region_overall = sum(mig_1_region,3:4) / sum(mig_1_region,"all");
mig_5_region_overall = sum(mig_5_region,3:4) / sum(mig_5_region,"all");
mig_10_region_overall = sum(mig_10_region,3:4) / sum(mig_10_region,"all");

%comment these lines to keep the non-migrant population (i.e., diagonal
%line)
for indexI = 1:8
    mig_1_region_overall(indexI,indexI) = 0;
    mig_5_region_overall(indexI,indexI) = 0;
    mig_10_region_overall(indexI,indexI) = 0;
end

%comment these lines to keep the NIU line, which drowns out the variation
%in mobility
mig_1_region_overall(end,:) = [];
mig_5_region_overall(end,:) = [];
mig_10_region_overall(end,:) = [];

mig1 = figure;
imagesc(mig_1_region_overall);
set(gca,'XTick',1:8,'XTickLabel',placeLabels,'YTick',1:10,'YTickLabel',placeLabels);
xlabel('Receiving (location now)');
ylabel('Sending (location 1 year ago');
title('1-year migration by grouped regions (fraction of total population)');
colorbar;
print('-dpng','-painters','-r150','mig_1yr.png');

mig5 = figure;
imagesc(mig_5_region_overall);
set(gca,'XTick',1:8,'XTickLabel',placeLabels,'YTick',1:10,'YTickLabel',placeLabels);
xlabel('Receiving (location now)');
ylabel('Sending (location 5 years ago)');
title('5-year migration by grouped regions (fraction of total population)');
colorbar;
print('-dpng','-painters','-r150','mig_5yr.png');

mig10 = figure;
imagesc(mig_10_region_overall);
set(gca,'XTick',1:8,'XTickLabel',placeLabels,'YTick',1:10,'YTickLabel',placeLabels);
xlabel('Receiving (location now)');
ylabel('Sending (location 10 years ago)');
title('10-year migration by grouped regions (fraction of total population)');
colorbar;
print('-dpng','-painters','-r150','mig_10yr.png');

save migData_census2013 popData mig_*;
