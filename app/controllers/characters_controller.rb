class CharactersController < ApplicationController
  include ApplicationHelper


  def home
    #home page
  end

  def start_game
    #game rules
    #form to input game params
  end



  def combat
    if !validate_params
      flash[:alert] = "Please make sure you enter both names and select a SEED number."
      @params = params
      redirect_to action: "start_game", name_1: params[:name_1], name_2: params[:name_2]#make sure we keep the params so the user doesn't have to re-enter
    else
      seed_number = params[:seed_number].to_i
      api_response_1 = get_character(params[:name_1])
      api_response_2 = get_character(params[:name_2])
      #we want to validate to make sure we got both responses and it was succesfull
      if api_response_1.is_a?(String) || api_response_2.is_a?(String)
        flash[:alert] = [api_response_1, api_response_2].select{|r| r.is_a?(String)}.first
        redirect_back fallback_location: root_path
      else
        #now we start building our characters for real
        begin
          data_1 = api_response_1["data"]["results"][0]
          character_1 = Character.new(name: data_1["name"], description: data_1["description"], image_url: (data_1['thumbnail']['path'] + '.jpg'))

          data_2 = api_response_2["data"]["results"][0]
          character_2 = Character.new(name: data_2["name"], description: data_2["description"], image_url: (data_2['thumbnail']['path'] + '.jpg'))
          if !character_1.save || !character_2.save#this should only happen if we get a succesfull response but there is no description data for existing character
            issue = [character_1, character_2].select{|c| c.try(:errors).try(:any?)}.first
            message = issue.errors.full_messages.first
            flash[:alert] = "#{issue.try(:name)}: #{message}"
            redirect_to action: "start_game", name_1: params[:name_1], name_2: params[:name_2]
          else
            results = find_winner(character_1, character_2, seed_number)
            redirect_to action: "results", name_1: params[:name_1], name_2: params[:name_2], winner: results, seed: seed_number #sending data to results

          end
        rescue
          flash[:alert] = "Issues with processing the request."
          redirect_back fallback_location: root_path
        end
      end
    end
  end

  def results #not proud of this one but in the lack of time I will take a working solution
    @seed_number = params[:seed].to_i
    api_response_1 = get_character(params[:name_1])
    data_1 = api_response_1["data"]["results"][0]
    @character_1 = Character.new(name: data_1["name"], description: data_1["description"], image_url: (data_1['thumbnail']['path'] + '.jpg'), url: data_1["urls"][0]["url"])

    api_response_2 = get_character(params[:name_2])
    data_2 = api_response_2["data"]["results"][0]
    @character_2 = Character.new(name: data_2["name"], description: data_2["description"], image_url: (data_2['thumbnail']['path'] + '.jpg'), url: data_2["urls"][0]["url"])

    @title = build_title(params["winner"])
  end

  def about
    #basic info
  end


  private

  def get_character(char_name)
    #FROM MARVEL DOCS:
    # Server-side applications must pass two parameters in addition to the apikey parameter:
    # ts - a timestamp (or other long string which can change on a request-by-request basis)
    # hash - a md5 digest of the ts parameter, your private key and your public key (e.g. md5(ts+privateKey+publicKey)
    #For example, a user with a public key of "1234" and a private key of "abcd" could construct a valid call as follows:
    #http://gateway.marvel.com/v1/public/comics?ts=1&apikey=1234&hash=ffd275c5130566a2916217b101f26150 (the hash value is the md5 digest of 1abcd1234)
    marvel_public_key =  Rails.application.secrets.marvel_public_key
    marvel_private_key =  Rails.application.secrets.marvel_private_key
    ts = DateTime.now.to_s
    #docs from https://ruby-doc.org/stdlib-2.4.0/libdoc/digest/rdoc/Digest/MD5.html
    hash = Digest::MD5.hexdigest( "#{ts}#{marvel_private_key}#{marvel_public_key}")
    api_link = "http://gateway.marvel.com/v1/public/characters?ts=#{ts}&apikey=#{marvel_public_key}&hash=#{hash}&name=#{char_name}"

    begin
     response = Faraday.get api_link
     response = JSON.parse(response.body)
    rescue Faraday::Error::ConnectionFailed => e #for failed connection
      flash[:alert] = "Connection failed: #{e}"
      redirect_back fallback_location: root_path
    end
    validate = validate_api_response(response)
    #if validation fails we just want to send an error message
    validate == true ? response : validate
  end

  def validate_params
    params[:name_1].present? && params[:name_2].present? && params[:seed_number].present?
  end

  def validate_api_response(response)
    if !response.present? || response["code"] != 200
      message = "Issue with a processing request. Please try again and make sure you enter both names correctly."#some response should always be present but just in case
      if response.present? && response["code"] != 200
        if response["message"].present? #looking for a more specific error when response hash will include message like faraday missing parameters/ "You must provide a user key."
          message = "Issue with a connection to Marvel APIt: #{response["message"]}"
        else
          message = response["status"].present? ? "Issue with a processing request: #{response["status"]}" : message #when we get a connection but error from the api
        end
      end
      message
    elsif response.present? && response["code"] == 200 && !response["data"]["results"].any? #when the response is success, but no data retrieved
      message = "No results for one or both characters. Please try again and make sure you spell the names correctly."
    else
      true
    end
  end

  def find_winner(character_1, character_2, seed_number)
    word_1 = character_1.word(seed_number)
    word_2 = character_2.word(seed_number)
    words = [word_1, word_2]
    magic_words = Character::MAGIC_WORDS
    #we are defining the winners
    if words.all?{|w| magic_words.include?(w)} || (words.none?{|w| magic_words.include?(w)} && (word_1.size == word_2.size))
      #draw if both have magic words or none have magic words and the word size is the same
      [character_1.name, character_2.name]
    else
      if [word_1, word_2].select{|w| magic_words.include?(w)}.any?
        #automatically Win if just one magic word
        winner = words.select{|w| magic_words.include?(w)}
      else#otherwise order by size and pick the winner
        winner = words.sort_by {|x| x.length}.last
      end
      (words.index(winner) == 0) ? character_1.name : character_2.name
    end
  end
end
