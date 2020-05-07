%whole population

clear
load tempInfragravityRegression.mat

logEvents = log10(eventsPerDay);

i = 1;


for n = 1:720
    if isnan(dailyAvgTemp(n)) == 0 && isinf(logEvents(n)) == 0
        G(i) = dailyAvgTemp(n);
        d(i) = logEvents(n);
        i = i +1;
    end
end

d = d';
G = [G',ones(length(G),1)];

m = G\d;

x = linspace(-60,0);
y = x *m(1) +m(2);
plot(x,y)
hold on
scatter(G(:,1),d)

pred = G(:,1)*m(1) +m(2);
res = pred - d;
ssr = sum(res.^2);
sst = var(d)*(numel(d)-1);
rSq = ssr/sst;

%swarms

clear
load tempInfragravityRegression.mat

logEvents = log10(eventsPerDay);

i = 1;


for n = 1:720
    if isnan(dailyAvgTemp(n)) == 0 && isinf(logEvents(n)) == 0 && eventsPerDay(n) >= 1
        G(i) = dailyAvgTemp(n);
        d(i) = logEvents(n);
        i = i +1;
    end
end

d = d';
G = [G',ones(length(G),1)];

m = G\d;

x = linspace(-60,0);
y = x *m(1) +m(2);
plot(x,y)
hold on
scatter(G(:,1),d)

pred = G(:,1)*m(1)+m(2);
res = pred - d;
ssr = sum(res.^2);
sst = var(d)*(numel(d)-1);
rSq = ssr/sst;
