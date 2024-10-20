class Search

  include ActiveModel::Model

  attr_reader :flights
  attr_accessor :dep
  attr_accessor :arr
  attr_accessor :dep_on
  attr_accessor :currency

  def initialize(atts = {})
    atts.each do |k, v|
      send "#{k}=", v
    end
  end

  def call
    make_request
    parse_flights
    persist
    @flights = find_all
  end

  def to_model
    self
  end

  %i[dep arr].each do |dep_arr|
    define_method "#{dep_arr}=" do |v|
      instance_variable_set :"@#{dep_arr}", v.upcase
    end
  end

  def currency=(c)
    @currency = Currency.new(c)
  end

 private

  def make_request
    @response = conn.post do |req|
      req.body = body
    end
    raise @response.body unless @response.success?
  end

  def parse_flights
    json = JSON.load(@response.body)
    #puts JSON.pretty_generate(json)
    @parsed_flights = SearchJsonParser.parse_all(json)
  end

  def persist
    @persister = SearchPersister.new(@parsed_flights)
    @persister.call
  end

  def find_all
    Flight.find(@persister.flight_ids)
  end

  def conn
    @conn ||= conn = Faraday.new(
      :url => URL,
      :headers => HEADERS,
    ) do |f|
      f.response :logger
    end
  end

  SW_CURRENCIES = {
    :points => 'POINTS',
    :cash   => 'USD',
  }

  def body
    {
      :adultPassengersCount     => "1",
      :departureDate            => @dep_on.to_s,
      :departureTimeOfDay       => "ALL_DAY",
      :destinationAirportCode   => @arr,
      :fareType                 => SW_CURRENCIES.fetch(@currency.type),
      :int                      => "LFCBOOKAIR",
      :lapInfantPassengersCount => "0",
      :originationAirportCode   => @dep,
      :passengerType            => "ADULT",
      :promoCode                => "",
      :returnAirportCode        => "",
      :returnDate               => "",
      :returnTimeOfDay          => "ALL_DAY",
      :selectedFlight1          => "",
      :selectedFlight2          => "",
      :tripType                 => "oneway",
      :application              => "air-booking",
      :site                     => "southwest",
    }.to_json
  end

  URL = 'https://www.southwest.com/api/air-booking/v1/air-booking/page/air/booking/shopping'
  HEADERS = {
    'accept'               => 'application/json, text/javascript, */*; q=0.01',
    'accept-language'      => 'en-US,en;q=0.9',
    'adrum'                => 'isAjax:true',
    'content-type'         => 'application/json',
    'cookie'               => 'swa_FPID=1baea91b-2baa-478f-bcc7-8432e2dc85f2; akaalb_alb_prd_southwest_spa=2147483647~op=PrdSouthwestSpaV1_lb:PrdSouthwestSpaV1|~rv=93~m=PrdSouthwestSpaV1:0|~os=6ebf11227eb877b88e3cfdc68a3ccb6c~id=2dd355b5ae8cc6062f612e44cf78c9e6; at_check=true; AMCVS_65D316D751E563EC0A490D4C%40AdobeOrg=1; _gcl_au=1.1.1459338371.1729283903; _cc=AR%2BraTHDGMhsU6B6hIyPNiVT; _cid_cc=AR%2BraTHDGMhsU6B6hIyPNiVT; s_ecid=MCMID%7C30842930538455691923305271868965195084; s_cc=true; nmstat=af429810-db06-859c-64f7-d114e26a653c; _mibhv=anon-1729283904697-9519310977_4971; _imp_apg_r_=%7B%22_rt%22%3A%22DQclZ69jgibf8CmquRG%2Bn70wOeCc3SC6wEwExzGyt68%3D%22%7D; _up=1.2.605229068.1729284019; valid_promo=false; akavpau_prd_non_vision=1729290291~id=5049ebc1e1cfc80de5927c1810913cf2; akavpau_prd_rogue_api=1729290465~id=10c3957096038af2ab0f4f03f10587fd; AMCV_65D316D751E563EC0A490D4C%40AdobeOrg=179643557%7CMCIDTS%7C20015%7CMCMID%7C30842930538455691923305271868965195084%7CMCAAMLH-1729896908%7C9%7CMCAAMB-1729896908%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1729299308s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C5.5.0; _cc-x=YzdlYmZlODQtYWFkMi00NDU5LWExZGYtMzY3ZDNlMDYzNmM0OjE3MjkyOTYyMDkyMTA; __ts_xfdF3__=383071797; sRpK_XA_swc=%7B%22c%22%3A%22UE1OaElMSGtKbGlnNXVsbQ%3D%3DLXBRGR1BboaUkxtu-tRHiByxmg3UNnPTphaIsl0VOjMVCdNGXim0cYJA6FW6r2bspJz8MP18RIISgyFBRi-xsRCG1mvWFuUYtWaz_n5hM_JYsf0wBmX7rhRdJYbbBskg86M%3D%22%2C%22dc%22%3A%22000%22%2C%22mf%22%3A0%7D; s_sq=swaprod%3D%2526c.%2526a.%2526activitymap.%2526page%253DBOOK%25253AAIR%25253ASelect%252520Flight%252520Page%2526link%253DLog%252520in%252520Opens%252520flyout.%252520Espa%2525C3%2525B1ol%252520DEC%25252030%252520OKC%252520LGAModify%252520Select%252520flights%252520Depart%25253A%252520OKCLGA%252520Oklahoma%252520City%25252C%252520OK%252520-%252520OKC%252520to%252520New%252520York%252520%252528LaGuardia%252529%25252C%2526region%253DBODY%2526pageIDType%253D1%2526.activitymap%2526.a%2526.c; ADRUM=s=1729298055495&r=https%3A%2F%2Fwww.southwest.com%2Fair%2Fbooking%2Fselect-depart.html%3Fhash%3D558846938; akavpau_prd_air_booking=1729298655~id=72215401658b45d480c2be75a34d147b; sRpK8nqm_sc=A6hJWqGSAQAAlsxnMiHAL4JPvKjd2-5bwa4Mn7YHpx0HDPGzMRT0zjF3tJ2kAWOiD0iucqPJwH9eCOfvosJeCA|1|0|99ff20e31d3d6bbdf624a73fc133e85728befa29; mbox=PC#34106990ed8145df8a06aa81c5c675fa.35_0#1792541010|session#bf12352bf851458683d5d3052455dc4d#1729299916; RT="z=1&dm=southwest.com&si=94d7db28-3d04-4b2d-a018-ebada5bb3080&ss=m2feba2c&sl=0&tt=0&bcn=%2F%2F17de4c13.akstat.io%2F"',
    'ee30zvqlwf-a'         => 'rxg95l05VVkvh9CtIGcw2YBiriq-EUyOh6dMqcn8j2jsnggwTDM4K7ndLjFXD2sNin53qCrP60kkHYm8nxY=NnxU8OoDwBmU2ZVT6FM1vu5ER2FRCKXET=AR7u0Kbzvjg=_KEaTyHYO922kln4tbADDux_Msk1Ln=f4ph1WB9kUDdfTQFonTjfDLODfQt0-sHGMIbhNouGcPgIFD5M30mCFtBjeehA3zKqLVeJfcQ5nLjfl6kKqa-B=25WykzW5gIia8iV4QEvh3LwbkTDy-VL1_HPwgHOL8rkwz=GskJ8oqksnsOWbn=gxXx_cafVodZrTkRB=8x3BHJAEfQ_6Q-lLNHerdWY5zPNb=_H5HkvmvdqZvMKDGTTfEG6dGA6DjEZfp1zG9jZTX9=J2tw8jO09T-hgA8K28UU0JGe5EZOc0iYvNaFlHIq7bER0cFzQ5eGFE=kZ0WWopNkdPVkeKptBlXfffp_-hipFEebrPUnbJnf59enpsbrHrt8Z4VFRwALqXj0LdMYZ0hCLw4bKDEHlhkYE=7L8wTu23CVitrMV9HqeuV9dhx0c8aL4-PIsCp7Os3ng1-teL4RjuZEWr251oJ23-24BR5UCRmao4ArMe1nt7aQ6b1d7UjPpfgLwE3caAYFgc68ZMdKq-Xzh0JW5ELWlc7Ia3FwoejW1iWL8=yEACm2MseMtBE9Wqx10pkPLIj6DTvago_Jt-lgWyyNjtvgpoDD3PDg4Jn2RkDjzuRLmUN7T7hAoYq1s=Ik8T_L3-tK56pw3satkw38hsFi3trAbLlPHOpda4eKKquOB47fNoOOqxZOfyJPnzqGGyNtcx3eBfkZtLPweX_9XhTMnriBgchuOkXLBHlsDVGVXjZxXkuBwWppZFTe2yGZnVAnjnCyeGpoWZLBvoT=Jg4piJWJqumUt5UtH7lEBMOz08oNikz==GXZ=FkUuvovvq5UDLJhn9X8g1FppyJnnuaPY5y7mla6z-GxGZ6AhgvPK0W-KwVm_1ocygG5TMYGvfDMFm82hTAlahaLiMrNmcrcELx6_gC4kZEuwgULb9LrupgD-Ka_ZRVshNftWFILQ9AuugjpEGwVN2BedqIFhDBN9O9IO84hTJk=yhJGj0svgj2063BxW2jMf3issZ-R0fQ64OqZjV_e=3fUmAbdgGu4KC3VEJElERY7LTuF-tVKq12K_mZ2A3s-Mo7xWEh3nDKqnWx-s9lGPiQA7f1xsb5O2b8o6KKxrxltdRCegjncrfn1fVPGhHLdR8OWaHIHR=CyKhdAc6zUp6CVoHqyg5YvPrPAYQCtrap-Eq7dBkb_07TNQ8=7oeqAyD_1jYQ4-T---JzaZ-dRtgHhPqj0me9iOD6hl3cI5txKj0UGsV9ygzAw6p=cjeG9BcAYRIBlOIzF5G0p1KzLTeJRzaFFbaYkpdcil8noijxa3eL4I=b1EO6WqqeYZqg-=oIs7crhKbNXcYZTd=5EpaJuI0wBkQ7UdK3hl6u-Vwy00u67CDBvwiCv1rLclv-QXY42PeEJRXQaRJ0L9PM2G-lLZMXZg82gCkasvR8o_NitKvfAHzaDcjdXVUulvk8BFUKRtaGWrgAaVyriqdjHpryA8YZ4sfJx0aT7VhaIAuWEO75lulNjqI9zreaVXvveeNprrWL0LCrQB0joklsl03yjEDgaF8tjRACiM17RU5U5VH-xYPp7Vf5P=RaUofEyKrxcxdn89cRvjLc0TqFH9cTyTExRgcdMXRr6u44GaHnFdQ_=9O6L1qT-1RG-8GcdZ8NugXC7WaCZrZs2QvU7UPElWCCpFTYN1POypUyMXQQZeEKYbKJe5u6nV64yIMfYbNQ0n96jiDV3W1AfjPAMajABzGPJuFEUiN34YavUlF2ZO6P=Wa3FPVcbOkcog6-Ibgzzaafw8ATfq_74-0VDaAD6I80oYpRmnVygoZ-Pc4El0-xUH5tghUO160MffFOzOEa1scLGeIH9HuRbwET=QhQDLKxjZNHEOc1-7zeN0yJ7cVzDt5kv8O_ALVubQ9tPemuDmZArdhEyYFDskPW7ebdrO9ojo=6c7o=hjrdFJAKwJ4',
    'ee30zvqlwf-b'         => 'tg53nn',
    'ee30zvqlwf-c'         => 'AEBbLqKSAQAAk9X7wGKHJA99LN_fN0I93HPm3cMcaAN3jPo-01i986LJCGZX',
    'ee30zvqlwf-d'         => 'ADaAhIDBCKGBgQGAAYIQgISigaIAwBGAzPpCxg_33ocx3sD_CABYvfOiyQhmVwAAAAAn36CjA8DYVUHv6KlnLH4v1HTdkHI',
    'ee30zvqlwf-f'         => 'AwlCMqKSAQAApOhL-vMyuVMGAxy-D8valnheBGQxcSuRKG1tYLHvwTE1g6EtAWOiD0iucqPJwH9eCOfvosJeCA==',
    'ee30zvqlwf-z'         => 'q',
    'origin'               => 'https://www.southwest.com',
    'priority'             => 'u=1, i',
    'referer'              => 'https://www.southwest.com/air/booking/select-depart.html?adultPassengersCount=1&departureDate=2024-12-30&departureTimeOfDay=ALL_DAY&destinationAirportCode=LGA&fareType=USD&int=LFCBOOKAIR&lapInfantPassengersCount=0&originationAirportCode=OKC&passengerType=ADULT&promoCode=&returnAirportCode=&returnDate=&returnTimeOfDay=ALL_DAY&selectedFlight1=2024-12-31&selectedFlight2=&tripType=oneway',
    'sec-ch-ua'            => '"Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"',
    'sec-ch-ua-mobile'     => '?0',
    'sec-ch-ua-platform'   => '"macOS"',
    'sec-fetch-dest'       => 'empty',
    'sec-fetch-mode'       => 'cors',
    'sec-fetch-site'       => 'same-origin',
    'user-agent'           => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
    'x-api-key'            => 'l7xx944d175ea25f4b9c903a583ea82a1c4c',
    'x-app-id'             => 'air-booking',
    'x-channel-id'         => 'southwest',
    'x-user-experience-id' => '82088716-52b2-4ed3-ad29-a8887fe29a45',
  }

end
