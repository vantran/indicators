# Function: 'STOCHRSI'
# Description: 'Stochastic Relative Strength Index'
module Indicators
  class StochRsi
    # %K = (RSI - Lowest Low RSI) / (Highest High RSI - Lowest Low RSI) * 100
    # %D = 3-day SMA of %K
    # Lowest Low = lowest low for the look-back period
    # Highest High = highest high for the look-back period
    # %K is multiplied by 100 to move the decimal point two places
    #
    # Full %K = Fast %K smoothed with X-period SMA
    # Full %D = X-period SMA of Full %K
    #
    # Input 3, 3, 14, 14
    # Returns [full %K, full %D]
    def self.calculate data, parameters
      k_period = parameters[0]
      d_period = parameters[1]
      rsi_period = parameters[2]
      stochastic_period = parameters[3]

      indicators_data = Indicators::Data.new(data)
      rsi_data = indicators_data.calc(type: :rsi, params: rsi_period).output["rsi"].compact

      ohlcv_data = rsi_data.map do |x|
        h = {}
        h[:open] = x
        h[:high] = x
        h[:low] = x
        h[:adj_close] = x
        h
      end

      indicators_data = Indicators::Data.new(ohlcv_data)
      output = indicators_data.calc(:type => :sto, :params => [stochastic_period, k_period, d_period]).output
      
      return output
    end
  end
end
