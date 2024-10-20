module PercentProgressBarHelper

  def percent_progress_bar(percent)
    content_tag 'div', :class => 'progress' do
      content_tag 'div', nil, :class => 'progress-bar', :style => "width: #{percent}%"
    end
  end

end
