=begin
	This class has basic time functions that let you add/subtract time from a reference time.
	Usage:
	1. time_math( operation, ref = Time.now, seconds = 0, minutes = 0, hours = 0, days = 0, months = 0, years = 0 )

	2. leap?( year ): Check if the year is leap
	3. time_diff( ref1, ref2 = Time.now ): Return a hash of days, hours, minutes, seconds and usec
	4. timed_out?(ttl): Use as a timer. First call sets the timer, and then ttl is checked on every subsequent calls.

=end

class TimeUtils

	@previous_ts = nil

	def leap?( year )
		return true if year % 100 == 0 and year % 400 == 0
		return true if year % 100 !=0 and year % 4 == 0
		return false
	end

	def time_diff( ref1, ref2 = Time.now )
		later = nil, former = nil
		if ref2 > ref1
			later = ref2; former = ref1
		else
			later = ref1; former = ref2
		end

		time_diff_i = later.to_i - formar.to_i
		time_diff_f = later.to_f - formar.to_f
		
		u_sec = time_diff_f.to_s.split(/\./)[1]
		sec = time_diff_i % 60
		min = ( time_diff_i / 60 ) % 60
		hours = ( time_diff_i / 3600 ) % 24
		days = ( time_diff_i / 3600 * 24 )

		{ :days => days, :hours => hours, :minutes => min, :seconds => sec, :usec => u_sec }
	end

	def time_math( operation, ref = Time.now, seconds = 0, minutes = 0, hours = 0, days = 0, months = 0, years = 0 )

		days_in_month = [ 31,28,31,30,31,30,31,31,30,31,30,31 ]
		days_in_leap_month = [ 31,29,31,30,31,30,31,31,30,31,30,31 ]

		month_days = 0; year_days = 0

		current_year = ref.year
		current_month = ref.month
		month_arr = days_in_month
		case
			when operation.match(/^add/i)
				months.times {
					current_month += 1
					if current_month > 11
						current_month = 0 ## reset month index
						current_year += 1	
					end
					month_arr = leap?( current_year ) ? days_in_leap_month : days_in_month
					month_days += month_arr[ current_month ]
				}

				## Add days in year.
				years.times {
					current_year += 1
					year_days += leap?( current_year ) ? 366 : 365
				}

				factor = 1
			when operation.match(/^sub/i)
				months.times {
					current_month -= 1
					if ( current_month < 0 )
						current_month = 11 ## reset month index
						current_year -= 1
					end
					month_arr = leap?( current_year ) ? days_in_leap_month : days_in_month
					month_days += month_arr[ current_month ]
				}
				years.times {
					current_year -= 1
					year_days += leap?( current_year ) ? 366 : 365
				}
				factor = -1
			else
				return "Unsupported Operation"
		end

		total_day_seconds = ( days + month_days + year_days ) * 24 * 60 * 60
		total_time_seconds = ( hours * 60 * 60 ) + ( minutes * 60 ) + seconds
		total_seconds = total_day_seconds + total_time_seconds
		return ref + ( factor * total_seconds )
	end
	
	def timed_out?(ttl)
	  current_ts = Time.now; time_out = true
	  if @previous_ts 
      @mutex ||= Mutex.new
      @mutex.synchronize {
		    time_diff = current_ts - @previous_ts
	      if time_diff > ttl
          puts("EXCEEDED TTL, ttl => #{ttl}, time_exceeded => #{time_diff}")
	  	    @previous_ts = current_ts  ## reset old time here
	        time_out = true
	      else
          puts("WITHIN TTL, ttl => #{ttl}, time_exceeded => #{time_diff}")
	        time_out = false
	      end
      }
    else
      puts("STARTING TIME FOR THE FIRST TIME with TTL #{ttl}")
  	  @previous_ts = current_ts
	  end
	  time_out
	end
	
end
