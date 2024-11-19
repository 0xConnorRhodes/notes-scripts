require 'date'
require 'pry'

NOTES_FOLDER = File.expand_path("~/notes")

def get_quarter_date_range month_int
    year_str = Date.today.strftime("%y")
    quarter_ranges = {
        q1: [2, 3, 4],
        q2: [5, 6, 7],
        q3: [8, 9, 10],
        q4: [11, 12, 1]
    }

    if quarter_ranges[:q1].include? month_int
        return {
            quarter: "FY#{year_str.to_i+1}Q1",
            start_date: (year_str + '0201').to_i, 
            end_date: (year_str + '0430').to_i
        }
    elsif quarter_ranges[:q2].include? month_int
        return {
            quarter: "FY#{year_str.to_i+1}Q2",
            start_date: (year_str + '0501').to_i, 
            end_date: (year_str + '0731').to_i
        }
    elsif quarter_ranges[:q3].include? month_int
        return {
            quarter: "FY#{year_str.to_i+1}Q3",
            start_date: (year_str + '0801').to_i, 
            end_date: (year_str + '1031').to_i
        }
    elsif quarter_ranges[:q4].include? month_int
        puts 'q4'
        if month_int == 1
            return {
                quarter: "FY#{year_str.to_i}Q4",
                start_date: ("#{year_str.to_i-1}" + '1101').to_i, 
                end_date: ("#{year_str.to_i}" + '0131').to_i
            }
        else
            return {
                quarter: "FY#{year_str.to_i+1}Q4",
                start_date: (year_str + '1101').to_i, 
                end_date: ("#{year_str.to_i+1}" + '0131').to_i
            }
        end
    end
end

q_dates = get_quarter_date_range(Date.today.strftime("%m").to_i)

binding.pry