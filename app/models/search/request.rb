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
    json = JSON.pretty_generate(JSON.parse(@response.body))
    File.open(Rails.root + "log/searches/#{Time.now}_#{@dep}_#{@arr}_#{@currency}.json", 'w') { |f| f.write json }
    raise @response.body unless @response.success?
    @response
  end

private

  URL = 'https://www.southwest.com/api/air-booking/v1/air-booking/page/air/booking/shopping'

  HEADERS = {
    'accept' => 'application/json, text/javascript, */*; q=0.01',
    'accept-language' => 'en-US,en;q=0.9',
    'adrum' => 'isAjax:true',
    'content-type' => 'application/json',
    'cookie' => 'swa_FPID=1baea91b-2baa-478f-bcc7-8432e2dc85f2; akaalb_alb_prd_southwest_spa=2147483647~op=PrdSouthwestSpaV1_lb:PrdSouthwestSpaV1|~rv=93~m=PrdSouthwestSpaV1:0|~os=6ebf11227eb877b88e3cfdc68a3ccb6c~id=2dd355b5ae8cc6062f612e44cf78c9e6; _gcl_au=1.1.1459338371.1729283903; _cc=AR%2BraTHDGMhsU6B6hIyPNiVT; _cid_cc=AR%2BraTHDGMhsU6B6hIyPNiVT; s_ecid=MCMID%7C30842930538455691923305271868965195084; nmstat=af429810-db06-859c-64f7-d114e26a653c; _mibhv=anon-1729283904697-9519310977_4971; _imp_apg_r_=%7B%22_rt%22%3A%22DQclZ69jgibf8CmquRG%2Bn70wOeCc3SC6wEwExzGyt68%3D%22%7D; _up=1.2.605229068.1729284019; sRpK8nqm_sc=A6hJWqGSAQAAlsxnMiHAL4JPvKjd2-5bwa4Mn7YHpx0HDPGzMRT0zjF3tJ2kAWOiD0iucqPJwH9eCOfvosJeCA|1|0|99ff20e31d3d6bbdf624a73fc133e85728befa29; PIM-SESSION-ID=o8rR0niros08ka2a; akavpau_prd_non_vision=1729718444~id=92a0e1d1b4073851f0bc459dc66b3ba1; at_check=true; AMCVS_65D316D751E563EC0A490D4C%40AdobeOrg=1; AMCV_65D316D751E563EC0A490D4C%40AdobeOrg=179643557%7CMCIDTS%7C20019%7CMCMID%7C30842930538455691923305271868965195084%7CMCAAMLH-1730322644%7C9%7CMCAAMB-1730322644%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1729725044s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C5.5.0; gpv_Page=HP%3ASWA%3ASouthwest%20Homepage; s_cc=true; sRpK_XA_swc=%7B%22c%22%3A%22QlFCQ1VEV3hWaEFaaGFSbg%3D%3D7MQ8p-BIbIZXPTnF6Lz66xmXLe7xXi9HCsr7g2xKuIObVjencaFXHnejQagSqTN7S_z695vFPL1JFQ0sXFuNNAJSDbIDAaKRSPtndNE6aHzhgXiGTHrog-j6JrClsZ2yuFw%3D%22%2C%22dc%22%3A%22000%22%2C%22mf%22%3A0%7D; s_sq=swaprod%3D%2526c.%2526a.%2526activitymap.%2526page%253DHP%25253ASWA%25253ASouthwest%252520Homepage%2526link%253DSearch%2526region%253DTabbedArea_4-panel-0%2526pageIDType%253D1%2526.activitymap%2526.a%2526.c; ADRUM=s=1729717871042&r=https%3A%2F%2Fwww.southwest.com%2F; akavpau_prd_air_booking=1729718471~id=3a620c526bc42489e3355be16d1e926e; mbox=PC#34106990ed8145df8a06aa81c5c675fa.35_0#1792962646|session#d18a03b4a7f94d77899de0d3b1cb2bd2#1729719732; RT="z=1&dm=southwest.com&si=94d7db28-3d04-4b2d-a018-ebada5bb3080&ss=m2mdcd6p&sl=1&tt=3oh&bcn=%2F%2F17de4c1d.akstat.io%2F"; _cc-x=N2VkOTk4MTQtODZkNi00NDNmLTkwOWUtODg1ZDljYTZkM2FiOjE3Mjk3MTc4NzE4NTA',
    'ee30zvqlwf-a' => 'Qpi75iPop8D0XFurEWi_pm5RbDAd7gWB806SwqIFIHu6=uMjAD2rvcWOwojZHwqOdzS9fkQiU9=M5m_NGsH80-=JxBKj_9nbNhVh9eQ8-39NVRBQD_r45yk6PibyZ_3YvsI9nc7yyBlc-ZwAbagk7jDVc22=aaaBeqyJloxMvfH2-_4RRx=2X4x_yGNtNmenF1ydBXwmzx=Uxq8hHUft4tMKmVJSBfkbAYRApkP=nFeSeRNofsbfY=DO0AY=eS0esdGA_Wu_2IBz90zM24n6Jz1NerWfjSlNOJxm3eeaIrdvKqFYSt=RAIbgkKjvpD_NczcfGKjR55wbHjLtCuGPMevyzLi6cjwIjQ77RSgwgApB9ovYE_PQkJ6od7mju-knwf2fY-jUq-ujN8F5hRXsGMQdH6EDu61YuAEY85pn-MSr2qxjl4Do_L40Lv8PfeZawf4LmfWEkZ0rcIDiokif0hGFnQHw=JH=b=arFSN1B_LpeLVQlXvoeX_514qs0sXs0HjJ8pURunMZQykMQdfQBKxIOr2pxCkqcNKZCXt0Na1fpgnqqL35iZsBbKDrIYE-sWgIdh51s7X0KMjNda6bs4ImfgbMikWZMnfH8U0WXguP=j6p039L-53WPpJQSLDXQey0MiypAsLv1zr-n6ZPfsRkbupvpDQHLiEGqUQw2_19HPdYrK5N8YionAQ8PpaIOzLEet2059IB59utR-WVNlKOPz0aPZu=eIkwdf3rAX0MIW9WiLmOQUKUqJREmiCVbNuBQdR23KwDlmEGYZardQmdrqFq5sLKraEaMXHZfiom0Rmu7N-aB7I-UXdxsKDMuQIXPo60Q71vJki8xmuRp_DkOW8Hm3xqdUJHSxIB7sK_KAs-DyIJWvASCx7HL3wrtZ4e4packbJt0tq1OFyLCPNFv3gbvGatQKXzABZ_ffFsIR=73Q3X5qOVLzQ=3mX==iJ3MVyRQyWD_5yZcMIxjPiqD-3rDZuGWWKqniG5qfWl3lhImxI7m=QdswAlbBYxx2G-=QSsO6mABRw--rdK3heR7dvmmS5PjdVMSnlBIlnLm9fchQMpwtrnFAdwH9L9goo8cxRNJegDroafy_gzbJEIFBKiD3C-UlvjipWG59e28JZnO0xwRdwjtYXkB33tPaVlvAVNwPaQE-z=fGh-=Gxt3kgSEGP9qmhaWuzBF203xts6Mk1_f81sn4WJCQIJUxyzu=gPteINay=DScUr9I1x2itc2Qnrts1SoZeJh7F7Lb90KnAhkJ-E-iFP2Gavy8DBU4DUuxysQaI7aWuyqcdeVzg0L8rh1OSYai_sB-f4ts3e3MpDg9Ubtay9ZFUOy00=frpxCXlHRdcJ8omc=skRCqB9cYGkMA1ikqDdloBm42Ds1oXUOUKOESZynjiuYDoMH27hwxhiPO8QBYpHwRhnu-aGHuiWwUp-iRRW5Suwex4DsyoSVs378dkPomA19IWjR_kLm49fKchh7xVRv1vUZGOEeDQn-e6XIPDMqc5kCXus3hDxRSm_B3VpK74mV006SQJGeISvzxD2forbOY7G8wmf=xMzecaKV4NyH2CMpADDbCX=4dIvCNDLxjnYKy7N7PvbhiBvoAUV4SGLUqXQvR8hAsx_FYDx8GfwQbV8LUkB7=HsQXyLxjddt8f6Js_MspE6q9Yp40PyB12uM0u5ep8N50OkSD_g5vIrEXaOukpbKrtspNbvXJOyzuuNofXgzqp1NZwMuV4JZIW0DMAIP7YKOEX93N84UVgynsWqNIOpnhuK7ApmhhqGKlHDqudrEOrii37ZPdb2Ix9WpFQpGP9FWqRJIz1N506Yzl4Wvb6D_qUdOgZj0DhfhS3lqcZRGhkN4c04Qe3JBASVPlUt_7RRhlLzUW17zPvLnFl3IDnYjYMd2LIyDn4fcnbYFiu5NrEC6O_W=XQalMFj81r3HURFFfbG7v8540ZLfkGIiHholiA5FKmhdVanhY2=Buh50kYZmwq2L-a4OEuqu-N2b5GSZLay6ALCVlah60F632wl9o10vZS2homA-wsp1zhEHoaC2OPL9wR1wZkjbc8gcoMhCnrafpzXpmjM1XdGHrq9dmU0-SSIgGPbIDd4Qm4q3bomcSAA5C369oJqkQnw_wvI',
    'ee30zvqlwf-b' => '-d6y5db',
    'ee30zvqlwf-c' => 'AEAMN7uSAQAAMak3QIBhKAWeGeeLiDDdQwIYgVRoGs8pEhNGycoitpuHcOET',
    'ee30zvqlwf-d' => 'ADaAhIDBCKGBgQGAAYIQgISigaIAwBGAzPpCxg_33ocx3sD_CADKIrabh3DhEwAAAAAn36CjA88tNaWqnlu99Bos0vx3LkY',
    'ee30zvqlwf-f' => 'A3EjOLuSAQAAUMmQdFWh-tISCFEgIxGfSXkYSbbH7wASzVdlgBISmpDQNerBAWOiD0iuct3FwH9eCOfvosJeCA==',
    'ee30zvqlwf-z' => 'q',
    'origin' => 'https://www.southwest.com',
    'priority' => 'u=1, i',
    'referer' => 'https://www.southwest.com/air/booking/select-depart.html?int=HOMEQBOMAIR&adultPassengersCount=1&departureDate=2024-12-29&destinationAirportCode=OKC&fareType=POINTS&originationAirportCode=HOU&passengerType=ADULT&promoCode=&returnDate=&tripType=oneway&from=HOU&to=OKC&adultsCount=1&departureTimeOfDay=ALL_DAY&reset=true&returnTimeOfDay=ALL_DAY',
    'sec-ch-ua' => '"Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"',
    'sec-ch-ua-mobile' => '?0',
    'sec-ch-ua-platform' => '"macOS"',
    'sec-fetch-dest' => 'empty',
    'sec-fetch-mode' => 'cors',
    'sec-fetch-site' => 'same-origin',
    'user-agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36',
    'x-api-key' => 'l7xx944d175ea25f4b9c903a583ea82a1c4c',
    'x-app-id' => 'air-booking',
    'x-channel-id' => 'southwest',
    'x-user-experience-id' => '82088716-52b2-4ed3-ad29-a8887fe29a45',
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
