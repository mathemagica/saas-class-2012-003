# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(movie)
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  body_str = page.body
  ordered_properly = /#{e1}.*#{e2}/m =~ page.body #!(body_str =~ /#{e1}([^"]*)#{e2}/).nil?
  ordered_properly.should be_true
end

Then /I should (not )?see movies with the following ratings: (.*)/ do |uncheck, rating_list|
  movies_by_rating_hash = {}
  Movie.all.each do |movie|
    if movies_by_rating_hash.keys.include?(movie.rating)
      movies_by_rating_hash[movie.rating] << movie.title
    else
      movies_by_rating_hash[movie.rating] = [movie.title]
    end
  end
  ratings = rating_list.gsub(/\[/, "").gsub(/\]/, "").gsub(/\'/, "").split(/,/)
  ratings.each do |rating|
    rating = rating.gsub(/\s/, "")

    movies_by_rating_hash[rating].each do |movie_title|
      if uncheck.blank?
        step 'I should see "' + movie_title +'"'
      else
        step 'I should not see "' + movie_title + '"'
      end
    end
  end

end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  ratings = rating_list.gsub(/\[/, "").gsub(/\]/, "").gsub(/\'/, "").split(/,/)
  ratings.each do |rating|
    rating = rating.gsub(/\s/, "")
    if uncheck.blank?
      step 'I check "ratings_' + rating + '"'
    else
      step 'I uncheck "ratings_' + rating + '"'
    end 

  end
end

Then /^I should see all of the movies$/ do
  all_movies_count = Movie.count
  page.all('table#movies tr').count.should == all_movies_count + 1 # all movies plus header
end

Then /^I should see none of the movies$/ do
  page.all('table#movies tr').count.should == 1
end

