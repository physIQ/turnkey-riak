require "logstash/filters/base"
require "logstash/namespace"

class LogStash::Filters::Level < LogStash::Filters::Base

  config_name "level"

  # New plugins should start life at milestone 1.
  milestone 1


  public
   def register
     # nothing to do
   end # def register

  #   Level   JUL         syslog      JCL
  #
  #    900    SEVERE      0-Emergency FATAL
  #    850                1-Alert     ERROR
  #    800                2-Critical
  #    750                3-Error
  #    700    WARNING     4-Warning   WARN
  #    600                5-Notice
  #    500    INFO        6-Info      INFO
  #    400    CONFIG
  #    300    FINE        7-Debug     DEBUG
  #    200    FINER
  #    100    FINEST                  TRACE

  public
  def filter(event)

    # return nothing unless there's an actual filter event
    return unless filter?(event)

    if @level
      event["level"] = @level
    end

    if event["level"]
      if ( event["level"] =~ /^([Cc]rit?(?:ical)?|CRIT?(?:ICAL)?|[Ff]atal|FATAL|[Ss]evere|SEVERE|EMERG(?:ENCY)?|[Ee]merg(?:ency)?|900|0)$/)
        event["level"] = "CRITICAL"
        event["level.code"] = 900
      elsif ( event["level"] =~ /^([Aa]lert|ALERT|[Ee]rr?(?:or)?|ERR?(?:OR)?|850|1)$/)
        event["level"] = "ERROR"
        event["level.code"] = 850
      elsif ( event["level"] =~ /^(800|2)$/)
        event["level"] = "ERROR"
        event["level.code"] = 800
      elsif ( event["level"] =~ /^(750|3)$/)
        event["level"] = "ERROR"
        event["level.code"] = 750
      elsif ( event["level"] =~ /^([Ww]arn?(?:ing)?|WARN?(?:ING)?|700|4)$/)
        event["level"] = "WARNING"
        event["level.code"] = 700
      elsif ( event["level"] =~ /^([Nn]otice|NOTICE|600|5)$/)
        event["level"] = "WARNING"
        event["level.code"] = 600
      elsif ( event["level"] =~ /^([Ii]nfo|INFO|[Dd]etail|DETAIL|[Ll]og|LOG|500|6)$/)
        event["level"] = "INFO"
        event["level.code"] = 500
      elsif ( event["level"] =~ /^([Cc]onfig|CONFIG|400)$/)
        event["level"] = "INFO"
        event["level.code"] = 400
      elsif ( event["level"] =~ /^([Dd]ebug|DEBUG|[Ff]ine|FINE|200|7)$/)
        event["level"] = "DEBUG"
        event["level.code"] = 300
      elsif ( event["level"] =~ /^([Ff]iner|FINER|200)$/)
        event["level"] = "DEGUG"
        event["level.code"] = 200
      elsif ( event["level"] =~ /^([Ff]inest|FINEST|[Tt]race|TRACE|100)$/ )
        event["level"] = "TRACE"
        event["level.code"] = 100
      end

    end

    filter_matched(event)
  end # def filter
end # class LogStash::Filters::Level
