module PercentProgressBarHelper

  COLORS = {
    (0..24)   => 'danger',
    (25..49)  => 'warning',
    (50..74)  => 'primary',
    (75..100) => 'success',
  }

  def percent_progress_bar(percent)
    color = COLORS.detect { |range, col| range.cover?(percent) }.last
    width = [percent, 1].max
    content_tag 'div', :class => 'progress' do
      content_tag 'div', nil, :class => ['progress-bar', "bg-#{color}"], :style => "width: #{width}%"
    end
  end

end
