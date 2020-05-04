rm(list = ls())

library(quantmod)
library(forecast)
library(ggplot2)
library(readxl)

getSymbols("AAPL")
getSymbols("GOOG")
getSymbols("TSLA")
getSymbols("FB")
getSymbols("INTC")
getSymbols("TMUS")
getSymbols("AMZN")
getSymbols("DJI")

start = "2020-03-05"
end = "2020-04-26"
apple = window(AAPL$AAPL.Adjusted, start = start, end = end)
google = window(GOOG$GOOG.Adjusted, start = start, end = end)
tesla = window(TSLA$TSLA.Adjusted, start = start, end = end)
facebook = window(FB$FB.Adjusted, start = start, end = end)
intel = window(INTC$INTC.Adjusted, start = start, end = end)
tmo = window(TMUS$TMUS.Adjusted, start = start, end = end)
amazon = window(AMZN$AMZN.Adjusted, start = start, end = end)
djia = window(DJI$DJI.Adjusted, start = start, end = end)

apple.pdiff = apple
for (i in 2:length(apple))
  apple.pdiff[i] = (as.numeric(apple[i]) - as.numeric(apple[i-1])) / as.numeric(apple[i-1])
apple.pdiff = window(apple.pdiff, start = time(apple.pdiff[2]))

google.pdiff = google
for (i in 2:length(google))
  google.pdiff[i] = (as.numeric(google[i]) - as.numeric(google[i-1])) / as.numeric(google[i-1])
google.pdiff = window(google.pdiff, start = time(google.pdiff[2]))

tesla.pdiff = tesla
for (i in 2:length(tesla))
  tesla.pdiff[i] = (as.numeric(tesla[i]) - as.numeric(tesla[i-1])) / as.numeric(tesla[i-1])
tesla.pdiff = window(tesla.pdiff, start = time(tesla.pdiff[2]))

facebook.pdiff = facebook
for (i in 2:length(facebook))
  facebook.pdiff[i] = (as.numeric(facebook[i]) - as.numeric(facebook[i-1])) / as.numeric(facebook[i-1])
facebook.pdiff = window(facebook.pdiff, start = time(facebook.pdiff[2]))

intel.pdiff = intel
for (i in 2:length(intel))
  intel.pdiff[i] = (as.numeric(intel[i]) - as.numeric(intel[i-1])) / as.numeric(intel[i-1])
intel.pdiff = window(intel.pdiff, start = time(intel.pdiff[2]))

tmo.pdiff = tmo
for (i in 2:length(tmo))
  tmo.pdiff[i] = (as.numeric(tmo[i]) - as.numeric(tmo[i-1])) / as.numeric(tmo[i-1])
tmo.pdiff = window(tmo.pdiff, start = time(tmo.pdiff[2]))

amazon.pdiff = amazon
for (i in 2:length(amazon))
  amazon.pdiff[i] = (as.numeric(amazon[i]) - as.numeric(amazon[i-1])) / as.numeric(amazon[i-1])
amazon.pdiff = window(amazon.pdiff, start = time(amazon.pdiff[2]))

djia.pdiff = djia
for (i in 2:length(djia))
  djia.pdiff[i] = (as.numeric(djia[i]) - as.numeric(djia[i-1])) / as.numeric(djia[i-1])
djia.pdiff = window(djia.pdiff, start = time(djia.pdiff[2]))

apple.pdiff.corrected = apple.pdiff - djia.pdiff
google.pdiff.corrected = google.pdiff - djia.pdiff
tesla.pdiff.corrected = tesla.pdiff - djia.pdiff
facebook.pdiff.corrected = facebook.pdiff - djia.pdiff
intel.pdiff.corrected = intel.pdiff - djia.pdiff
tmo.pdiff.corrected = tmo.pdiff - djia.pdiff
amazon.pdiff.corrected = amazon.pdiff - djia.pdiff

dat = cbind(apple.pdiff, google.pdiff, tesla.pdiff, facebook.pdiff, intel.pdiff, tmo.pdiff, amazon.pdiff, djia.pdiff)
colnames(dat) = c("Apple", "Google", "Tesla", "Facebook", "Intel", "T-Mobile", "Amazon", "DJIA")
autoplot(dat, facets = FALSE)
autoplot(cbind(apple.pdiff.corrected, google.pdiff.corrected, tesla.pdiff.corrected, facebook.pdiff.corrected, intel.pdiff.corrected, tmo.pdiff.corrected, amazon.pdiff.corrected), facets = FALSE)

autoplot(tesla.pdiff)
autoplot(cbind(tesla.pdiff, djia.pdiff), facets = FALSE)
autoplot(tesla.pdiff.corrected)




#########################
# Import sentiment scores
#########################

tesla.sent = read_excel("SentimentScoresAverage.xlsx")
tesla.sent$Date = as.Date(tesla.sent$Date)
tesla.sent = xts(x = cbind(tesla.sent$Polarity, tesla.sent$Subjectivity, tesla.sent$`Aggregate Score`), order.by = tesla.sent$Date)
colnames(tesla.sent) = c("Polarity", "Subjectivity", "Aggregate.Score")

# Plot

autoplot(cbind(scale(tesla.pdiff.corrected), scale(tesla.sent)), facets = FALSE)

df = cbind(scale(tesla.pdiff.corrected), scale(tesla.sent$Aggregate.Score))
colnames(df) = c("Tesla Stock Movement", "Aggregate Score")
autoplot(df, facets = FALSE)
df = cbind(scale(tesla.pdiff.corrected), -scale(tesla.sent$Polarity))
colnames(df) = c("Tesla Stock Movement", "Polarity")
autoplot(df, facets = FALSE)
df = cbind(scale(tesla.pdiff.corrected), scale(tesla.sent$Subjectivity))
colnames(df) = c("Tesla Stock Movement", "Subjectivity")
autoplot(df, facets = FALSE)


# Fit models

acc = function(dat)
{
  sum = 0
  
  for (i in 1:length(dat[,1]))
  {
    if (dat$pred.move[i] == -1)
      if (dat$truth[i] <= -0.005)
        sum = sum + 1
    if (dat$pred.move[i] == 1)
      if (dat$truth[i] >= 0.005)
        sum = sum + 1
    if (dat$pred.move[i] == 0)
      if (-0.01 <= dat$truth[i] & dat$truth[i] <= 0.01)
        sum = sum + 1
  }
  
  return(sum / length(dat[,1]))
}

tesla.comb = cbind(tesla.pdiff.corrected, tesla.sent)
colnames(tesla.comb)[1] = "index"
cor(tesla.comb$index, tesla.comb$Polarity, use = "pairwise.complete.obs")
cor(tesla.comb$index, tesla.comb$Subjectivity, use = "pairwise.complete.obs")
cor(tesla.comb$index, tesla.comb$Aggregate.Score, use = "pairwise.complete.obs")
tesla.matrix = data.frame(tesla.comb)
colnames(tesla.matrix) = c("index", "Polarity", "Subjectivity", "Aggregate.Score")
days = nrow(tesla.matrix)
Polarity.1 = c(NA, as.vector(tesla.comb$Polarity[1:(days-1)]))
Polarity.2 = c(NA, NA, as.vector(tesla.comb$Polarity[1:(days-2)]))
Polarity.3 = c(NA, NA, NA, as.vector(tesla.comb$Polarity[1:(days-3)]))
Subjectivity.1 = c(NA, as.vector(tesla.comb$Subjectivity[1:(days-1)]))
Subjectivity.2 = c(NA, NA, as.vector(tesla.comb$Subjectivity[1:(days-2)]))
Subjectivity.3 = c(NA, NA, NA, as.vector(tesla.comb$Subjectivity[1:(days-3)]))
tesla.matrix = cbind(tesla.matrix, Polarity.1, Polarity.2, Polarity.3, Subjectivity.1, Subjectivity.2, Subjectivity.3)
tesla.train = window(xts(tesla.matrix, order.by = as.Date(rownames(tesla.matrix))), end = "2020-4-10")
tesla.test = window(xts(tesla.matrix, order.by = as.Date(rownames(tesla.matrix))), start = "2020-4-11")
tesla.lm = lm(index ~ Polarity + Subjectivity, data = tesla.matrix)
summary(tesla.lm)
tesla.lm = lm(index ~ Polarity.1 + Polarity.2 + Polarity.3 + Subjectivity.1 + Subjectivity.2 + Subjectivity.3, data = tesla.train)
summary(tesla.lm)
df = cbind(xts(predict(tesla.lm, newdata = tesla.train), order.by = time(tesla.train)), window(tesla.pdiff.corrected, end = "2020-4-10"))
colnames(df) = c("Predicted Stock Movement", "Actual Stock Movement")
autoplot(df, facets = FALSE) + ggtitle("Training Data")
pred = predict(tesla.lm, newdata = tesla.test)
df = cbind(xts(predict(tesla.lm, newdata = tesla.test), order.by = time(tesla.test)), window(tesla.pdiff.corrected, start = "2020-4-11"))
colnames(df) = c("Predicted Stock Movement", "Actual Stock Movement")
autoplot(df, facets = FALSE) + ggtitle("Test Data")
pred.move = ifelse(pred >= 0.005, yes = 1, no = ifelse(pred <= -0.005, yes = -1, no = 0))
pred.move = xts(pred.move, order.by = as.Date(names(pred.move)))
test = cbind(pred.move, window(tesla.pdiff.corrected, start = "2020-4-11"))
test = na.omit(test)
colnames(test) = c("pred.move", "truth")
print(acc(test))
pred = predict(tesla.lm, newdata = tesla.matrix)
df = cbind(xts(pred, order.by = as.Date(rownames(tesla.matrix))), tesla.pdiff.corrected)
colnames(df) = c("Predicted Stock Movement", "Actual Stock Movement")
autoplot(df, facets = FALSE) + ggtitle("All Data")
pred.move = ifelse(pred >= 0.005, yes = 1, no = ifelse(pred <= -0.005, yes = -1, no = 0))
pred.move = xts(pred.move, order.by = as.Date(names(pred.move)))
test = cbind(pred.move, tesla.pdiff.corrected)
test = na.omit(test)
colnames(test) = c("pred.move", "truth")
print(acc(test))

# Trying with a sliding window (swa = sliding window average)

for (window in 1 + 2*(0:4))
{
  tesla.comb.swa = tesla.comb
  for (i in floor(window/2):(length(tesla.comb.swa$Polarity)-floor(window/2)))
  {
    tesla.comb.swa$Polarity[i] = mean(tesla.comb$Polarity[(i-floor(window/2)):(i+floor(window/2))])
    tesla.comb.swa$Subjectivity[i] = mean(tesla.comb$Subjectivity[(i-floor(window/2)):(i+floor(window/2))])
    tesla.comb.swa$Aggregate.Score[i] = mean(tesla.comb$Aggregate.Score[(i-floor(window/2)):(i+floor(window/2))])
  }
  print(cor(tesla.comb.swa$index, tesla.comb.swa$Polarity, use = "pairwise.complete.obs"))
  print(cor(tesla.comb.swa$index, tesla.comb.swa$Subjectivity, use = "pairwise.complete.obs"))
  print(cor(tesla.comb.swa$index, tesla.comb.swa$Aggregate.Score, use = "pairwise.complete.obs"))
}

# Try with uncorrected stock movement

tesla.comb = cbind(tesla.pdiff, tesla.sent)
colnames(tesla.comb)[1] = "index"
window = 3
tesla.comb.swa = tesla.comb
for (i in floor(window/2):(length(tesla.comb.swa$Polarity)-floor(window/2)))
{
  tesla.comb.swa$Polarity[i] = mean(tesla.comb$Polarity[(i-floor(window/2)):(i+floor(window/2))])
  tesla.comb.swa$Subjectivity[i] = mean(tesla.comb$Subjectivity[(i-floor(window/2)):(i+floor(window/2))])
  tesla.comb.swa$Aggregate.Score[i] = mean(tesla.comb$Aggregate.Score[(i-floor(window/2)):(i+floor(window/2))])
}
print(cor(tesla.comb.swa$index, tesla.comb.swa$Polarity, use = "pairwise.complete.obs"))
print(cor(tesla.comb.swa$index, tesla.comb.swa$Subjectivity, use = "pairwise.complete.obs"))
print(cor(tesla.comb.swa$index, tesla.comb.swa$Aggregate.Score, use = "pairwise.complete.obs"))


# Plot

  # Plotting negative because the correlation is negative
df = cbind(scale(tesla.pdiff.corrected), -scale(tesla.comb.swa$Aggregate.Score))
colnames(df) = c("Tesla Stock Movement", "-Aggregate Score")
autoplot(df, facets = FALSE)
df = cbind(scale(tesla.pdiff.corrected), -scale(tesla.comb.swa$Polarity))
colnames(df) = c("Tesla Stock Movement", "-Polarity")
autoplot(df, facets = FALSE)
df = cbind(scale(tesla.pdiff.corrected), -scale(tesla.comb.swa$Subjectivity))
colnames(df) = c("Tesla Stock Movement", "-Subjectivity")
autoplot(df, facets = FALSE)

# Output predictions to file

pred = predict(tesla.lm, newdata = tesla.matrix)
dat = cbind(pred, ifelse(pred >= 0.005, yes = 1, no = ifelse(pred <= -0.005, yes = -1, no = 0)))
dat = na.omit(dat)
write.table(x = dat, sep = " ", file = "Tesla-predict.txt")













