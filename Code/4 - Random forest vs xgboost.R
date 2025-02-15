# First run code 1, 2, 3

## VARIABLE IMPORTANCE

# rf: imp_rf1
imp_xgb1 <- imp_xgb[, 2:3]
colnames(imp_xgb1) <- c("XGB", "var")
import <- merge(imp_xgb1, imp_rf1, by = "var")
scaling<- function(x){
  out=(x-min(x))/(max(x)-min(x))
}
import$RF <- scaling(import$RF)
import$XGB <- scaling(import$XGB)
import <- import[order(import[,"XGB"], decreasing = T), ]

library("reshape2")
df.long <- melt(import,)
df.long %>%
  arrange(variable, desc(value)) %>%
  mutate(var = factor(var, levels = unique(var))) %>%
  ggplot() + aes(x = var, y = value, fill = variable) +
  geom_col(position = "dodge") +
  scale_fill_manual("legend", values = c("RF" = "#69b3a2", "XGB" = "orange")) +
  labs(x = "variabili", y = "importanza")
  
## PDP PLOT
# pdp for feature 'edfc' (change this input to obtain pdp for other vars)
# rf
library("iml")
mod_rf <- Predictor$new(model = rf_tuned, data = data_train_rf)
pdp_rf <- FeatureEffect$new(mod_rf, feature = 'edfc', method = 'pdp')
pdp_rf <- pdp_rf$results

# xgb
library("pdp")
pdp_xgb <- partial(object = model1, pred.var = 'edfc',
                   train = train.X, type = 'regression', plot.engine = 'ggplot2')

par(mfrow=c(2,1), oma = c(2,0,1,1) + 0.1)
par(mar = c(0,5,2,1) + 0.1)
# pdp
plot(pdp_rf$edfc, pdp_rf$.value, type="l", main = "PDP # edifici", xlab = "",
     ylab = "danno relativo predetto", ylim = c(0.09, 0.22), lwd = 2, xaxt = "n",
     bty = "n", xlim = c(0, 18))
axis(side = 1, at = seq(0.0, 18.0, by = 3), labels = c(rep("", 7)), lwd.ticks = 1)
lines(pdp_xgb$edfc, pdp_xgb$yhat, col = "red", lwd = 2)
legend(4, 0.20, legend = c("RF", "XGB"), col = c("black", "red"), lty = 1, 
       cex = .8, box.lty = 0, lwd = 2)

# density distribution 
par(mar = c(1,5,2,1), bty = "n")
hist(data_train_rf$edfc, xlim = c(0, 18), xaxt = "n",
     main = "Distribuzione", ylab = "densità", xlab = "mt", bty = "n",
     col = "tan1", freq = F, breaks = 15)
axis(side = 1, at = c(0, 18), labels = c("",""), lwd.ticks = 0)
axis(side = 1, at = seq(0.0, 18.0, by = 3), lwd = 0, lwd.ticks = 1)
