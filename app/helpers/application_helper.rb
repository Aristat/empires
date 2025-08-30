module ApplicationHelper
  def season(month_number)
    case month_number
    when 12, 1, 2 then 'Winter'
    when 3, 4, 5  then 'Spring'
    when 6, 7, 8  then 'Summer'
    when 9, 10, 11 then 'Autumn'
    end
  end

  # Map arbitrary color names to Bootstrap contextual text classes for consistency
  # Accepted inputs: 'red', 'green', 'yellow', 'blue', 'info', 'warning', 'danger', 'success', 'primary', 'secondary', 'muted', 'dark', 'light'
  # Returns a string like 'text-danger'
  def bootstrap_text_class(color)
    key = color.to_s.strip.downcase
    mapped = case key
             when 'red', 'danger' then 'danger'
             when 'green', 'success' then 'success'
             when 'yellow', 'warning' then 'warning'
             when 'blue', 'primary' then 'primary'
             when 'info' then 'info'
             when 'secondary' then 'secondary'
             when 'muted' then 'muted'
             when 'light' then 'light'
             when 'dark' then 'dark'
             else 'body' # default neutral text color
             end
    mapped == 'body' ? 'text-body' : "text-#{mapped}"
  end
end
