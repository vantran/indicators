module Indicators
  #
  # Relative Strength Index
  class Rsi

    #               100
    # RSI = 100 - --------
    #              1 + RS
    # RS = Average Gain / Average Loss
    # First Average Gain = Sum of Gains over the past 14 periods / 14
    # First Average Loss = Sum of Losses over the past 14 periods / 14
    # Average Gain = [(previous Average Gain) x 13 + current Gain] / 14.
    # Average Loss = [(previous Average Loss) x 13 + current Loss] / 14.
    def self.calculate data, parameters
      periods = parameters
      output = Array.new
      avg_gain_array = Array.new
      avg_loss_array = Array.new
      result = {}
      # alpha = (1/14.0).to_d
      alpha = 2.0 / (1 + periods)

      adj_closes = Indicators::Helper.validate_data(data, :adj_close, periods)

      average_gain = 0.0
      average_loss = 0.0
      adj_closes.each_with_index do |adj_close, index|
        if index >= periods
          if index == periods
            average_gain = gain_or_loss(adj_closes[0..index], :gain) / periods
            average_loss = gain_or_loss(adj_closes[0..index], :loss) / periods
          else
            difference = adj_close - adj_closes[index-1]
            if difference >= 0
              current_gain = difference
              current_loss = 0
            else
              current_gain = 0
              current_loss = difference.abs
            end
            average_gain = (average_gain * (periods-1) + current_gain) / periods
            average_loss = (average_loss * (periods-1) + current_loss) / periods
            # average_gain = average_gain * (1 - alpha) + (alpha * current_gain)
            # average_loss = average_loss * (1 - alpha) + (alpha * current_loss)
          end
          average_gain = average_gain.round(8) if average_gain
          average_loss = average_loss.round(8) if average_loss

          avg_gain_array[index] = average_gain
          avg_loss_array[index] = average_loss

          if average_gain == 0
            output[index] = 0
          elsif average_loss == 0
            output[index] = 100
          else
            rs = (average_gain / average_loss)
            output[index] = (100 - 100/(1+rs)).round(8)
          end
        else
          output[index] = nil
        end
      end

      result['avg_gain'] = avg_gain_array
      result['avg_loss'] = avg_loss_array
      result['rsi'] = output

      return result

    end

    #
    # Helper methods for RSI
    def self.gain_or_loss data, type
      sum = 0.0
      first_value = nil
      data.each do |value|
        if first_value == nil
          first_value = value
        else
          if type == :gain
            if value > first_value
              sum += value - first_value
            end
          elsif type == :loss
            if value < first_value
              sum += first_value - value
            end
          end
          first_value = value
        end
      end
      return sum
    end

  end
end