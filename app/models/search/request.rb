class Search::Request

  attr_reader :response

  def initialize(dep, arr, dep_on, currency)
    @dep      = dep
    @arr      = arr
    @dep_on   = dep_on
    @currency = currency
  end

  def call
    @response = conn.post do |req|
      req.body = body
    end
    raise @response.body unless @response.success?
    log_response
    @response
  end

private

  def log_response
    json = JSON.pretty_generate(JSON.parse(@response.body))
    File.open(Rails.root + "log/searches/#{Time.now}|#{@dep}-#{@arr}|#{@dep_on}|#{@currency}.json", 'w') { |f| f.write json }
  end

  URL = 'https://www.southwest.com/api/air-booking/v1/air-booking/page/air/booking/shopping'

  HEADERS = {
    'accept'               => 'application/json, text/javascript, */*; q=0.01',
    'accept-language'      => 'en-US,en;q=0.9',
    'adrum'                => 'isAjax:true',
    'content-type'         => 'application/json',
    'cookie'               => 'swa_FPID=7b0caf99-e776-4133-8099-3f540aae561f; akaalb_alb_prd_southwest_spa=2147483647~op=PrdSouthwestSpaV1_lb:PrdSouthwestSpaV1|~rv=5~m=PrdSouthwestSpaV1:0|~os=6ebf11227eb877b88e3cfdc68a3ccb6c~id=692dfe15df911378ea0586f10272c65f; PIM-SESSION-ID=LwLEI4DdVQHpPRYN; sRpK8nqm_sc=A94sHiKUAQAAYzyU2I9QaxbgtepK1WEtimzgWM2KpZmhaxAVNxr4gg08CotDAWOiD0iucu_LwH9eCOfvosJeCA|1|0|8cc3c1d083c5ba699c6d65cff6bc69be3b637243; at_check=true; akavpau_prd_non_vision=1735739791~id=371991e68befe270433f8c932c16a716; AMCVS_65D316D751E563EC0A490D4C%40AdobeOrg=1; _gcl_au=1.1.74083915.1735739191; sRpK_XA_swc=%7B%22c%22%3A%20%22NlRvZWlhM096NVF1aTRIdw%3D%3DfN5gu9wKRrFvgnpzotUJ28Uba1GPVl-zAOP19d4Z7-CcufhEd9BC9UYWFesvW1q0v6Vc8_f6KDi1zPiDxiLtzfe7ftIWvLnrKg8JuUnwC3kNzGVjFJQLl_4Zqlvoonq_S-o%3D%22%2C%20%22dc%22%3A%20%22000%22%2C%20%22mf%22%3A%200%7D; s_ecid=MCMID%7C76457690186350908661224273702686097348; AMCV_65D316D751E563EC0A490D4C%40AdobeOrg=179643557%7CMCIDTS%7C20090%7CMCMID%7C76457690186350908661224273702686097348%7CMCAAMLH-1736343991%7C7%7CMCAAMB-1736343991%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1735746392s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C5.5.0; QSI_SI_00nJZ3kWwSkWqKW_intercept=true; gpv_Page=HP%3ASWA%3ASouthwest%20Homepage; s_cc=true; nmstat=efff952a-6346-c44d-f1fb-b0c1e6cb7379; _mibhv=anon-1735739195134-5218825840_4971; QuantumMetricSessionID=3455a610df1f766dbdf6d9f1304ef132; QuantumMetricUserID=e92c1b4279b55e9c2db93c084878ba65; s_sq=swaprod%3D%2526c.%2526a.%2526activitymap.%2526page%253DHP%25253ASWA%25253ASouthwest%252520Homepage%2526link%253DSearch%2526region%253DTabbedArea_4-panel-0%2526pageIDType%253D1%2526.activitymap%2526.a%2526.c; ADRUM=s=1735739211198&r=https%3A%2F%2Fwww.southwest.com%2F; akavpau_prd_air_booking=1735739811~id=4740d8bc373f368ee26f57e95a8b5337; mbox=session#1de73c96e6644f08867d610e3ac58697#1735741072|PC#1de73c96e6644f08867d610e3ac58697.35_0#1798983993; RT="z=1&dm=southwest.com&si=9589ed71-dc73-4b37-9e62-09af0ec625dd&ss=m5dyaqeu&sl=1&tt=2nw&rl=1"; _cc-x=ODljZTJlNGEtZDM1Ny00NjAzLTgxODgtMWI0ZWViOWU1ZDViOjE3MzU3MzkyMTE4MTc; _up=1.2.1276098124.1735739212',
    'ee30zvqlwf-a'         => 'MY_Aew5WbIdldH_iMlk2-369qRnGU-IhuvZGhA2sNBsbKRVdrLQzjWPt1uQU-a=NMHhYLHPXlvnKN3iIJl437ZFwQUkAwIL1XJ1LksSAMMW0mC8T9HcybCD3Pt3c_i23=yAv9L=aLMG=2DI-j_Q1lteqsMXNee3wpHkAuaoPbY0BA=m-sSEVPzaA5pk2oDjp1jvE9LGsUreLJz2auEHAh5LYjjP_oUwQENIzSo87V-fai1rOp50a7NOT-mJTumkMsbNGvnC=w7sHhgLrylvQhGsHOdcIuPHy1bjJ5ZO4Tfw3zY4Ioaiajkr-ebMnNNMm7r_ZuoohRpwG5R_fMEN8e2_s30yZGakLBHL3k4zkW_rPGKaZO8P_h_PoY5bYpr_zSlffTqNasEHyJPCO7MZPWiKXZhZAn74tPG5LewRdyMa83ZdgZEh9EZtVSbePIUIOg5nesiQ4lw8Dba9tPPsTzof96QU3fquqhjhfyIahryJMXiRuGL9jR5=YLfqz1ACyVY=eCKjzL8EhkTydju0WcbSTb6vcFJNeembb2nuEBsZISE0e_WAt5hHMzJQqq60OC1NooKrjaWBof_PumjVcUCUA1Whk__wJ3K17zGP0vuniOsATTos18vOz9HaGR=9IBflrKYmS024vlnZdCrJ-5552OmG7kmNmHAT_jyIrYwKZP30XwZBtuJPpImUTlvgVYEDrY0XwyNf9PRPZCTwDBXHvaCmCIfVCRLBR8ZrH5ZMqHgjtYY6T9YlXcvsP6AyuOLMhcjJS49ZQIBNQUGoZbDa_s-50-tQOsFFiboJvXPXDkEzYV3FrWtzf087M8dXv9p7HLWaUpWF_4emeJNN4pygKHiAQkiEB4iup9Gtdu8MZtm21yZfjcqj_69Ha67hOCaLBjqY2SH7TpFwhkXNK7qz4-0TWhkQS2lAleMwKpS_G9Gn_UXlzW38L-Vu4-Chj0HqZStY9iouE=4lX=KKGHAKdFEwpAmqEu8nZBTud6zyUyyaQeC_MqOhAGtdEVotRZU6o2yfa-IXfVjkLEM4OvKaLrGh52m=RsnzyjjgMsR-NVzUOckuGEe_3lZzudzOYiwujHADy5ssPUivvNuaOQqamGwO4OKheFsXweoYoQfYKS33EMtq5kGs4UNV4gNoFmnIXtFRHwO1fCIMob-AnFiSeG6S=fy0zRDeaXgVmoJbc2Ejp8Sq=BJYsF5=IJUIIND4-pOYl971nDDaSGH5dzg9J-jkRFAEk-SMLi31_hBqRmM-MTbd0KXy9XvtlZQ8o6VrXlcnyUf5skKgDNOl-N9lcD0fXXhpo8n=d6UGpwK2yIsS5CjiqNewXMQ-E-iEHY9A8Nd_pWqCh0wVKQeKEGjGzKd_d6cCMrOvCtaXiB5mDdWIL3ssjRoEh4wBmOSVuW_nXT0y_V=yKvbKgNBucMbyW5ZfFC8DEf-5OmJ6h_mE-51rvE1LybbsOkMtdUhm2LKGfX1QmC7r4Bl1HN-GU8OQPG3rUorn5je-_QmhGca0abg3IhSj-0HksmQZ80yFmm6cLsf-Eczny9TOM=QTPrdjyhCDTtT02hNyBBV6glB=h33QcpPFwqOX2QAz_aMOYy6MhJd4r4ryHpdCP2qqktPBDzQ6WFBrLTKXXLGMt110IUtm_S-uKg4QgRdmMYK6QQeKZBg56AG3uMpZkdc2ofy2YgvBJSm1RNeU1rGFHibNruLNpb9hIHA9m-IFmp_sXMbiNyVgLby55Zq5d4z1LPGdbVWoOC0raYbzrJ6JKKMDdpJnsoCLdz_AwL0jO8650wFozjVvJ1bRhgzZzrrKgezL-Jes9fBPy663BInul_NA4cldWmrzYnHDF5cMQdFhz1KmeDW5etIo7ioBQ4TWUNALrEUD1ju6g4iu59mMo67KbgulfQWpE6TG5N4044hsgaMD0Nm2VAGGbhLJtDVOKD6dC23N-z_J=TSC5848zhD_RQO1ejAV4C4pJv8AeVu4KQ8q29FKWYNvrkGnGBC7mtPsjrwnuX8jhwt0iRwEQ_7Afhc143blgk6Wc-RpoXVR9i-CtrV9QOUsLCdBZosff=Wo78CHfFPabh9W4V=zKhrIMqt-euA8=MgfRLSXlCzw_ARjnVU=oSCXOeIKMM=Flv1-jB6y63GNs-sdp138dC=pp2KX1YvpQ=ZVEYi1nGKkeoW4=b9pChynbACWulEV=7Z1iN87Q1LO9H6sRcf=nwctqqZql',
    'ee30zvqlwf-b'         => '-60xlyo',
    'ee30zvqlwf-c'         => 'AGDLHCKUAQAASxMj9FQZdTg7NXKNP5y-kr4oRZiiAVDd5AdeXSPTHtPmFnD7',
    'ee30zvqlwf-d'         => 'ADaAhIDBCKGBgQGAAYIQgISigaIAwBGAzPpCxg_33ocx3sD_CAAj0x7T5hZw-wAAAAAAcX1dA4HUK80hEFDlqNqdcnjAeg0',
    'ee30zvqlwf-f'         => 'A2R-HiKUAQAAd8mMIx-7VCxRnwmK96fB5z8qnWyQP_05bHstmwLmWpYDoMw-AWOiD0iucu_LwH9eCOfvosJeCA==',
    'ee30zvqlwf-z'         => 'q',
    'origin'               => 'https://www.southwest.com',
    'priority'             => 'u=1, i',
    'referer'              => 'https://www.southwest.com/air/booking/select-depart.html?int=HOMEQBOMAIR&adultPassengersCount=1&departureDate=2025-01-16&destinationAirportCode=HOU&fareType=POINTS&originationAirportCode=OKC&passengerType=ADULT&promoCode=&returnDate=&tripType=oneway&from=OKC&to=HOU&adultsCount=1&departureTimeOfDay=ALL_DAY&reset=true&returnTimeOfDay=ALL_DAY',
    'sec-ch-ua'            => '"Google Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
    'sec-ch-ua-mobile'     => '?0',
    'sec-ch-ua-platform'   => '"macOS"',
    'sec-fetch-dest'       => 'empty',
    'sec-fetch-mode'       => 'cors',
    'sec-fetch-site'       => 'same-origin',
    'user-agent'           => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    'x-api-key'            => 'l7xx944d175ea25f4b9c903a583ea82a1c4c',
    'x-app-id'             => 'air-booking',
    'x-channel-id'         => 'southwest',
    'x-user-experience-id' => '2acfb419-e9c9-4e90-b424-e608c3ccfbdd',
  }

  SW_CURRENCIES = {
    :points => 'POINTS',
    :cash   => 'USD',
  }

  def conn
    @conn ||= conn = Faraday.new(
      :url => URL,
      :headers => HEADERS,
    ) do |f|
      f.response :logger
    end
  end

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

end
