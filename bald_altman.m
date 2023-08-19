% results

data1 = puls_ecg;
data2 = puls_estimated;

data_mean = (data1+data2)/2;
data_diff = data1 - data2; 
k=3
md = mean(data_diff);               
sd = std(data_diff); 
               
figure(5)
plot(data_mean(1:9),data_diff(1:9),'ok','MarkerSize',k,'LineWidth',k,'color',[0.3010 0.7450 0.9330])   
hold on
plot(data_mean(9:18),data_diff(9:18),'ok','MarkerSize',k,'LineWidth',k,'color',[0.9290 0.6940 0.1250])  
plot(data_mean(18:27),data_diff(18:27),'ok','MarkerSize',k,'LineWidth',k,'color',[0.8500 0.3250 0.0980])  
plot(data_mean(27:36),data_diff(27:36),'ok','MarkerSize',k,'LineWidth',k,'color',[0.4940 0.1840 0.5560])  
plot(data_mean(36:45),data_diff(36:45),'ok','MarkerSize',k,'LineWidth',k,'color',[0.4660 0.6740 0.1880])  
plot(data_mean,md*ones(1,length(data_mean)),'-k')             
plot(data_mean,2*sd*ones(1,length(data_mean)),'-k')                   
plot(data_mean,-2*sd*ones(1,length(data_mean)),'-k')             
grid on
title('Bland Altman','FontSize',10)
xlabel('srednja vrijednost','FontSize',10)
ylabel('razlika','FontSize',10)
