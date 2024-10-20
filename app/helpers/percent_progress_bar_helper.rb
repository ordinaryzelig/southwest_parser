module PercentProgressBarHelper

  COLORS = {
    (0..24)   => 'bg-success',
    (25..49)  => 'bg-primary',
    (50..74)  => 'bg-warning',
    (75..100) => 'bg-danger',
  }

  def percent_progress_bar(percent)
    color = percent_progress_bar_color(percent)
    width = [percent, 1].max
    content_tag 'div', :class => 'progress' do
      content_tag 'div', nil, :class => ['progress-bar', color], :style => "width: #{width}%"
    end
  end

  def percent_progress_bar_color(percent)
    COLORS.detect { |range, col| range.cover?(percent) }.last
  end

end
