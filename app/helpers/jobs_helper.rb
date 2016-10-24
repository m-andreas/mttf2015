module JobsHelper
  def get_abroad_hours time
    unless time.nil? || time.to_time.nil?
      return time.to_time.to_s(:time).split(":").first
    else
      return ""
    end
  end
  def get_abroad_minutes time
    unless time.nil? || time.to_time.nil?
      return time.to_time.to_s(:time).split(":").last
    else
      return ""
    end
  end

  def get_html_abroad_time jobs
    string = "<strong>Gesamt Auslandzeit: #{@job.get_abroad_time}</strong><br>"
    jobs.legs.each_with_index do |leg, i|
      string << "<br>Teilstrecke #{ i + 1 }: " + AbroadTime.calc(  leg.abroad_time_start, leg.abroad_time_end ).to_s
    end
    return string.html_safe
  end
end
