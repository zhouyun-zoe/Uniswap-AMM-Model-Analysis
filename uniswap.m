% numercial analysis in uniswap ETH-DAI market

clear;
clc;
close all;

price_change_ratio = (-0.7:0.01:0.7);
trading_vol= (5e4:10000:20e6);
fee_rate=(0.001:0.001:0.01);
initial_committed_capital=500;

% 10/2019
% Source: https://etherscan.io/address/0x09cabec1ead1c0ba254b09efb3ee13841712be14
% initial_ETH_pool_size = 8054;
% initial_DAI_pool_size = 1394469;
% ETH_price0 = 173;
% initial_committed_capital = 500;
% add_rate = 0.5;

[PL,MM_value1] = profit_loss(8054,1394469,173,500,0.5);
[PL2,MM_value2] = profit_loss(8054,1394469,173,500,0.3);

% For trader----------------------------------------------------------
% A plot for price change rate as the trade size
x=(-1:0.01:1);
y=(1+x).^2-1;
figure(1);
plot(x,y);
xlabel('\Deltay/y');
ylabel('Price change rate');
axis([-1 1 -0.8 1]);
grid on;


% For market maker-----------------------------------------------------

selected_fee_rate = 0.003;
ind4 = find(fee_rate==selected_fee_rate);
PL_R = PL(:,:,ind4);

% A plot for profitability for a certain percentage of price change
selected_price_change_percentage1 = 0.20;
ind1 = find(abs(price_change_ratio-selected_price_change_percentage1)<0.001);
selected_price_change_percentage2 = -0.20;
ind2 = find(abs(price_change_ratio-selected_price_change_percentage2)<0.001);
selected_price_change_percentage3 = 0.40;
ind3 = find(abs(price_change_ratio-selected_price_change_percentage3)<0.001);

figure(2);
plot(trading_vol/1e6,PL_R(ind1,:)/initial_committed_capital*100 ...
     ,trading_vol/1e6,PL_R(ind2,:)/initial_committed_capital*100 ...
     ,trading_vol/1e6,PL_R(ind3,:)/initial_committed_capital*100 ...
     );
ylabel('P/L [%]');
xlabel('Trading Volume [$ Million]');
% title('P/L percentage for different price change')
legend('20% of price change', '-20% of price change','40% of price change');
grid on;

% A plot for a certain trading volume
selected_trading_vol1 = 5e5;
ind11 = find(trading_vol==selected_trading_vol1);
selected_trading_vol2= 5e6;
ind22 = find(trading_vol==selected_trading_vol2);
selected_trading_vol3 = 20e6;
ind33 = find(trading_vol==selected_trading_vol3);

figure(3);
plot(price_change_ratio*100,PL_R(:,ind11)/initial_committed_capital*100 ...
     ,price_change_ratio*100,PL_R(:,ind22,:)/initial_committed_capital*100 ...
     ,price_change_ratio*100,PL_R(:,ind33,:)/initial_committed_capital*100 ...
);
ylabel('P/L [%]');
xlabel('Price Change [%]');
grid on;
legend('$0.5M trading vol', '$5M trading vol','$20M trading vol');

% A plot for different scenarios of exchange trading volume and ETH price change
figure(4);
imagesc(trading_vol/1e6,(price_change_ratio)*100,PL_R/initial_committed_capital*100)
ylabel('ETH price change [%]');
xlabel('Trading Volume [$ Million]');
title('P/L [%]');
grid on;
caxis([-10,3]);

% A plot for different position
figure(5);

selected_trading_vol2= 20e6;
ind22 = find(trading_vol==selected_trading_vol2);
selected_fee_rate = 0.003;
ind4 = find(fee_rate==selected_fee_rate);

MM_value100 = MM_value1(:,ind22,ind4);
MM_value60 = MM_value2(:,ind22,ind4);
MM_HODL = initial_committed_capital*0.5+initial_committed_capital*(1+price_change_ratio)*0.5
MM_dai = initial_committed_capital;
MM_eth = initial_committed_capital*(1+price_change_ratio);

plot(price_change_ratio*100,MM_value100 ...
     ,price_change_ratio*100,MM_value60 ...
     ,price_change_ratio*100,MM_HODL ...
     ,price_change_ratio*100,MM_dai ...
     ,price_change_ratio*100,MM_eth ...
     );
ylabel('MM Value');
xlabel('Price Change [%]');
% axis([-0.4 0.4 480 520]);
grid on;
legend('100% at uniswap', '60% at uniswap','HODL ETH/DAI','HODL DAI','HODL ETH');


%  For admin------------------------------------------------------------

selected_fee_rate1 = 0.001;
ind41 = find(fee_rate==selected_fee_rate1);
selected_fee_rate2 = 0.003;
ind4 = find(fee_rate==selected_fee_rate2);
selected_fee_rate3 = 0.005;
ind42 = find(fee_rate==selected_fee_rate3);

PL_41 = PL(:,:,ind41);
PL_4 = PL(:,:,ind4);
PL_42 = PL(:,:,ind42);

figure(6);
subplot(1,3,1);
imagesc(trading_vol/1e6,(price_change_ratio)*100,PL_41/initial_committed_capital*100)
ylabel('ETH price change [%]');
xlabel('Trading Volume [$ Million]');
title('P/L [%] with 0.001 fee rate');
caxis([-10,3]);

subplot(1,3,2);
imagesc(trading_vol/1e6,(price_change_ratio)*100,PL_4/initial_committed_capital*100)
ylabel('ETH price change [%]');
xlabel('Trading Volume [$ Million]');
title('P/L [%] with 0.003 fee rate');
caxis([-10,3]);

subplot(1,3,3);
imagesc(trading_vol/1e6,(price_change_ratio)*100,PL_42/initial_committed_capital*100)
ylabel('ETH price change [%]');
xlabel('Trading Volume [$ Million]');
title('P/L [%] with 0.005 fee rate');
caxis([-10,3]);

%
% PL Function/ Value function
%

function [PL,MM_value] = profit_loss(initial_ETH_pool_size,initial_DAI_pool_size,ETH_price0,initial_committed_capital,add_rate)

initial_pool_size = initial_DAI_pool_size+initial_ETH_pool_size*ETH_price0;

Uniswap_const_product = initial_ETH_pool_size*initial_DAI_pool_size; 
percentage_ownwership = initial_committed_capital*add_rate*2/initial_pool_size;

% Commited_DAI*Commited_DAI = Uniswap_const_product
% ETH_price = Commited_DAI/Commited_ETH
% Initial_committed_capital = Commited_DAI + Commited_ETH*ETH_price;

Commited_DAI0 = add_rate*initial_committed_capital;
Commited_ETH0 = add_rate*initial_committed_capital/ETH_price0;

% assuming a change of ETH price with no external change of the liquidity pool size

price_change_ratio= (-0.7:0.01:0.7);
trading_vol= (5e4:10000:20e6);
fee_rate=(0.001:0.001:0.01);

MM_new_ETH_share = zeros(length(price_change_ratio),length(trading_vol),length(fee_rate));
MM_new_DAI_share = zeros(length(price_change_ratio),length(trading_vol),length(fee_rate));

PL = zeros(length(price_change_ratio),length(trading_vol),length(fee_rate));

for ii = 1:length(price_change_ratio)
    for jj = 1:length(trading_vol)
        for kk = 1:length(fee_rate)
        ETH_price_change_ratio = price_change_ratio(ii);
        new_ETH_price = ETH_price0*(1+ETH_price_change_ratio);
        trading_volume = trading_vol(jj);
        fee_rates = fee_rate(kk);
        trading_fees = fee_rates*trading_volume;
%         Fees added to the pool assuming average price       
%         avg_price_of_move = (ETH_price0+new_ETH_price)/2;
%         ETH_added_to_pool = 0.5*trading_fees/avg_price_of_move;
%         DAI_added_to_pool = 0.5*trading_fees;
        
        % Fees added assuming uniform volume segments during the price move
        no_of_price_steps = 10;
        fees_per_price = trading_fees/no_of_price_steps;
        intermidate_price_steps=linspace(ETH_price0,new_ETH_price,no_of_price_steps);  %assuming linear price increase
        ETH_added_to_pool = sum(0.5*fees_per_price./intermidate_price_steps);
        DAI_added_to_pool = 0.5*trading_fees;
        
        DAI_pool_size = sqrt(Uniswap_const_product*new_ETH_price)+DAI_added_to_pool;
        ETH_pool_size = DAI_pool_size/new_ETH_price+ETH_added_to_pool;
        
        MM_new_ETH_share(ii,jj,kk) = percentage_ownwership*ETH_pool_size;
        MM_new_DAI_share(ii,jj,kk) = percentage_ownwership*DAI_pool_size;
        
        MM_new_position = MM_new_DAI_share(ii,jj,kk)+MM_new_ETH_share(ii,jj,kk)*new_ETH_price;
        position_without_MM = Commited_DAI0+Commited_ETH0*new_ETH_price;
        position_with_only_ETH = initial_committed_capital/ETH_price0*new_ETH_price;
        position_with_only_Dai = initial_committed_capital;
        
        PL(ii,jj,kk) = MM_new_position-position_without_MM;
        PLE = MM_new_position-position_with_only_ETH;
        PLD = MM_new_position-position_with_only_Dai;
          
        MM_value (ii,jj,kk) =  MM_new_position + (1-2*add_rate)*initial_committed_capital;


        end
    end
end

end
