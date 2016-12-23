########################################################################################################
# 												       #
# 				   Created By: Adam Wexler					       #
# 				   Ruby Program to Extract Data on Soccer	     	       	       #
# 				   Data Source: http://www.espnfc.us/api/scorebar		       #
# 												       #
########################################################################################################

require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'Pry'
require 'csv'
require 'spreadsheet'

# 	Symbolizes the Match Object

class Match
	def initialize(teamA, teamB, fScore, date)
		@teamA = teamA
		@teamB = teamB
		@fScore = fScore
		@date = "#{date.year}-#{date.month}-#{date.day}"
	end

	def printMatchInfo
		match_details = "Home Team: #{@teamA}\t Away Team: #{@teamB}\t Score: #{@fScore}\t Date: #{@date}"
		return match_details
	end

	def getTeamA
		return @teamA
	end

	def getTeamB
		return @teamB
	end

	def getScore
		return @fScore
	end

	def getDate
		return @date
	end

end

# 	Initialization of Program

s_leagues = []
match_data = []
teamA_data = []
teamB_data = []
score_data = []
date_data = []
count = 0
file = File.new("../sheets/#{Date.today}.txt", 'w')
score_book = Spreadsheet::Workbook.new
daily_scores = score_book.create_worksheet :name => 'Daily Scores'
format = Spreadsheet::Format.new :number_format => 'YYYY-MM-DD'

# 	Program below will parse data

scores = HTTParty.get("http://www.espnfc.us/api/scorebar")
scores_json = scores.parsed_response


scores_json["leagues"].each do |league|
	if count != 0
		s_leagues.push(league["html"])
	end
	count+=1
end

s_leagues.each do |page|
	f_page = Nokogiri::HTML(page)

	f_page.css(".scorebar-league").css(".score").css(".scorebox-container").each do |child|
		score_string = "#{child.css(".score-content").css(".team-scores").css(".team-score").children[0].text} - #{child.css(".team-scores").css(".team-score").children[1].text}" 
		teamA_string = "#{child.css(".score-content").css(".team-names").css(".team-name").children[0].text}"
		teamB_string = "#{child.css(".score-content").css(".team-names").css(".team-name").children[1].text}"
		match_data.push(Match.new(teamA_string, teamB_string, score_string, Date.today))
	end
end

teamA_data.push("Home Team")
teamB_data.push("Away Team")
score_data.push("Score")
date_data.push("Date")

# Initializing Data for .txt & csv files

match_data.each do |match|
	file.puts(match.printMatchInfo)
	teamA_data.push(match.getTeamA)
	teamB_data.push(match.getTeamB)
	score_data.push(match.getScore)
	date_data.push(match.getDate)
end

count = 0

daily_scores.column(3).default_format = format
match_data.each do |match|

	daily_scores.row(count).push(match.getTeamA)
	daily_scores.row(count).push(match.getTeamB)
	daily_scores.row(count).push(match.getScore)
	daily_scores.row(count).push(match.getDate)

	count+=1
end

score_book.write "../sheets/#{Date.today}.xls"

file.close





# Another method of doing the Excel file

table = [teamA_data, teamB_data, score_data, date_data].transpose

CSV.open("../sheets/#{Date.today}.csv", 'w') do |csv|
    table.each do |row|
        csv << row
    end
end


