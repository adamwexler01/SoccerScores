########################################################################################################
# 																									   #
# 						Created By: Adam Wexler														   #
# 						Ruby Program to Extract Data on Soccer										   #
# 						Data Source: http://www.espnfc.us/api/scorebar								   #
# 																									   #
########################################################################################################

require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'Pry'
require 'csv'

# 	Symbolizes the Match Object

class Match
	def initialize(teamA, teamB, fScore, date)
		@teamA = teamA
		@teamB = teamB
		@fScore = fScore
		@date = date
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

# 	Program below will parse data


scores = HTTParty.get("http://www.espnfc.us/api/scorebar")
scores_json = scores.parsed_response

s_leagues = []
match_data = []
teamA_data = []
teamB_data = []
score_data = []
date_data = []

count = 0
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

file = File.new("#{Date.today}.txt", 'w')

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

table = [teamA_data, teamB_data, score_data, date_data].transpose

CSV.open("#{Date.today}.csv", 'w') do |csv|
    table.each do |row|
        csv << row
    end
end

file.close


