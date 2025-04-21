module ApplicationHelper
    def season(month_number)
        case month_number
        when 12, 1, 2
            "Winter"
        when 3, 4, 5
            "Spring"
        when 6, 7, 8
            "Summer"
        when 9, 10, 11
            "Autumn"
        end
    end
end
