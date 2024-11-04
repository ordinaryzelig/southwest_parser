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
    File.open(Rails.root + "log/searches/#{Time.now}_#{@dep}_#{@arr}_#{@dep_on}_#{@currency}.json", 'w') { |f| f.write json }
    raise @response.body unless @response.success?
    @response
  end

private

  URL = 'https://www.southwest.com/api/air-booking/v1/air-booking/page/air/booking/shopping'

  HEADERS = {
    'accept'               => 'application/json, text/javascript, */*; q=0.01',
    'accept-language'      => 'en-US,en;q=0.9',
    'adrum'                => 'isAjax:true',
    'content-type'         => 'application/json',
    'cookie'               => 'swa_FPID=1baea91b-2baa-478f-bcc7-8432e2dc85f2; akaalb_alb_prd_southwest_spa=2147483647~op=PrdSouthwestSpaV1_lb:PrdSouthwestSpaV1|~rv=93~m=PrdSouthwestSpaV1:0|~os=6ebf11227eb877b88e3cfdc68a3ccb6c~id=2dd355b5ae8cc6062f612e44cf78c9e6; _gcl_au=1.1.1459338371.1729283903; _cc=AR%2BraTHDGMhsU6B6hIyPNiVT; _cid_cc=AR%2BraTHDGMhsU6B6hIyPNiVT; s_ecid=MCMID%7C30842930538455691923305271868965195084; nmstat=af429810-db06-859c-64f7-d114e26a653c; _mibhv=anon-1729283904697-9519310977_4971; _imp_apg_r_=%7B%22_rt%22%3A%22DQclZ69jgibf8CmquRG%2Bn70wOeCc3SC6wEwExzGyt68%3D%22%7D; _up=1.2.605229068.1729284019; _gcl_gf=GCL.1729736184.ADowPOKN1x4QCANPu_anPdxnDwsTZOcCtQelQ6Or-CJXE6CLX1U6xMDDLnGYjIyFnNbLKyrbF1GfeTQmaux0iAJRZPvtNqVgD1VJwLgbqJpAM1-tUTx7; sRpK8nqm_sc=A6hJWqGSAQAAlsxnMiHAL4JPvKjd2-5bwa4Mn7YHpx0HDPGzMRT0zjF3tJ2kAWOiD0iucqPJwH9eCOfvosJeCA|1|0|99ff20e31d3d6bbdf624a73fc133e85728befa29; PIM-SESSION-ID=xfkzjvFfgRoHMJHI; akavpau_prd_non_vision=1730735891~id=e76d8244c8da6cf69df54fce5c56c49d; at_check=true; AMCVS_65D316D751E563EC0A490D4C%40AdobeOrg=1; AMCV_65D316D751E563EC0A490D4C%40AdobeOrg=179643557%7CMCIDTS%7C20032%7CMCMID%7C30842930538455691923305271868965195084%7CMCAAMLH-1731340091%7C9%7CMCAAMB-1731340091%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1730742491s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C5.5.0; gpv_Page=HP%3ASWA%3ASouthwest%20Homepage; s_cc=true; sRpK_XA_swc=%7B%22c%22%3A%22ZkpUYnk0WUJ6OXpvdWxEWg%3D%3D8DgtwiN4JQDUZzrkikETa46cpWABVPnQ_JDJt8GiTtF8LW83RAg70ar_NFa7JtiU-1UEWQCwQeCP-TQJrsh25u0gWap4z8e6QIgn3573KJOKq7c042NL27IKln7z4BMeRSI%3D%22%2C%22dc%22%3A%22000%22%2C%22mf%22%3A0%7D; s_sq=swaprod%3D%2526c.%2526a.%2526activitymap.%2526page%253DHP%25253ASWA%25253ASouthwest%252520Homepage%2526link%253DSearch%2526region%253DTabbedArea_4-panel-0%2526pageIDType%253D1%2526.activitymap%2526.a%2526.c; ADRUM=s=1730735314052&r=https%3A%2F%2Fwww.southwest.com%2F; akavpau_prd_air_booking=1730735914~id=bd7121209026cd418ea214a9dc2da54b; mbox=PC#34106990ed8145df8a06aa81c5c675fa.35_0#1793980092|session#8a6e4470fc724d24bac99754093981a1#1730737175; RT="z=1&dm=southwest.com&si=94d7db28-3d04-4b2d-a018-ebada5bb3080&ss=m3373rxt&sl=1&tt=3j1&bcn=%2F%2F17de4c10.akstat.io%2F"; _cc-x=YmUwZDAxNTktNWM4OC00NjlhLTllNDgtNTc5Y2IyYTc2YWY4OjE3MzA3MzUzMTQ3MjY',
    'ee30zvqlwf-a'         => 'xYyhA3TrMrpStkDAt5mOkz0s5tXyqkBy4atsi2uiWDqdtdi4ABXF4RGmwPl3=8IhNdCliFkJMph9Kv9WkOeAZFx3y_rWcW0keexvfixgNq6-a_Rr8-ujH1e2CzfR_yzZBbxQh-3rreiZOeS8QFACp-nOXrcuV4Qeh9Q-N84GkKKadwWaFWxvkoLumVX9QR7_LxwnkCiMm=wKvqxM8jrJJc2nUscn5gPxpycev7nRR_Xh7mMI0HNj=Iv-YeXgcWxQ0zQxPY58GaO3JsO3cKer8deyUr8lmBc7Rob-mYaSTpKiCa8ouVBixSpOgDOsJNBudBy-fgJK06L01gplW6xk6VqeTD2rcYoxl5hOU85map2lB-VfAZTiMjL9BVJav1FGUwrLRLayeGPt5qm32eo85==nBJ47qrlAL=oyFquO5GxycJ_u3cvqX6cBkBWgk3AuNf3k0SX4NO0LyVBnDKI1enO1twwZUAx2ZmKjyKTRZb536sDnYFpiIKMuuo70o2jQHBQ-vHo16yR59ppbCQDuXQ0M1kjnFNvjqnxqx2afsMzxkDs9qo=5kwW=ZlCqbWdSak-=K4IQgH=NdYx5HkcGpZ8=FqBKRGozNI5XUJY52QGfR2pBPjKHfMA3a9vAR6Vpp1kuqMgnai0oHq4zORBgNN9o3ujvd1NKbHg-Kt78B8DhpTu-hBoM0NH8LjBU3u02NCKcfnqoQemJR4SZicb27hAx=h8eaSuXMbl1tsOpBceQx-NvBqJdM8sCTfbhJ4nc8Rl0JIez7=2dl6CJTMya-SnKsZX1w1lZvrLcbTuU8BjQ3vXf=CRraiebnvJBN-AvWvexzTzYc0Ym=2PMHhjlNWN_oDC-jN6m5N9eBr25yD6w_XiWgtONfOsJBeZK_oLpgrAyvvhw3_ulSbWOympFdZsT9OlXpzyMqvy86eLl7NaDJqkL68Pt_g_SDmBBZ1One3BJWiU=Q_ziui2_ukP1Cjk_Z8Qx3tBr6wDvyGW03a9ysf6NP0FZOo5znliaQbFp8RlMmtx-IHH0uPl0YUlsf36KV99lX_WuySvrH0601SQp=grd0NjPeLLvcZWNbd5_FMfPPBNPIH=NyfO0uxfUgacMJTuvTrqrD87FydR1zPIrdVqoaDpe7m1gaMhyPiAMK=9jp858MDt96MD=5el_1nTtz18twCawFrFo=4jXPc42ehnNfTQWC_XCP6=ugLR45ue98f1sQUo7JVIB1QiKH50Qay1yhTf1HrvbUceolT9-RWBcXWj23504pt8R_d6wNUoSq8_jK3emhSjrVCClQqkM9mnuS37bIl_0kAO54OXvAPBCptppP=zvvsuALG=YQ-DvTh0WR9YeIv8_pTfk7u3q4n6mU9igC=musL8UXty7-4u04bDGJpTOpd1WgsiHFd5otfoOFqqW6-xs9T1yoSjJ94iPYn2J5pv-i8=6k8f7xIpYxPClO06YmHZ0t2PCMmRD-hOsS-r7xrdoBwF-XPTMNPm0pHnLnH_mhuLdUgVB8-VHMVPPZf2ze5u0=Fj4m5Mz2fufXw-YveKQS69e_R5WiP707RmhLuF5n7Tbx66Kpc4rAU0ak=KWDVnCj4f7l4is0jQi-ZpVZ39dsjJIJPLfBz9aQXgrG5sAnQJZSTmx2P2ZQOirmmuT_4TtnTw6m1DRzL8pzIuuaKAu=vvQh7PvbACBWOVTlVXRQjl5mdyF6vuMJfYkd-qi6XOReLMjiBtCkGpLMBhWhdmpmn3ba1PpzvLmKGbisIgFbewBydx_Cbx-p3HqMCj32KTbSiNPSsOL0RaWW_QfKrb7Txv43pY7LAVarMQjT-QMOIh4-2eN72UK3LCP0vOfINXN9jzg4CvwP4pZ7RsZJ8pdAQHe2yXIYrCr3nZmZlO0IpZV1S0wX80OtZkYRUYzXpLVaK0__38_YZwbdr_pg1iFYkA4QAHVBNkpb6hwwzh6zyJcvfjMalpf8TjotYjg11wpHeMS_lZx36HuuDf_0yTqK1jqlc5mHCf-u2BFBA4tUOz0axCfJUN9B4JqIRonOC08x3IFfh7=Yv5ON5oqTJQZ73bMvm8Up9sVicCaGkgLsUIaFVeq3IKQhUP-mAuFzsMC2OMb',
    'ee30zvqlwf-b'         => 'favcs3',
    'ee30zvqlwf-c'         => 'AGDQ2feSAQAAZyZG-TEPnZMIbgQZr203FAOdUpoIJqeq5I8SJaTLeh2iRwOf',
    'ee30zvqlwf-d'         => 'ADaAhIDBCKGBgQGAAYIQgISigaIAwBGAzPpCxg_33ocx3sD_CACky3odokcDnwAAAAAn36CjA7BkhVcgrAew2vmYQKVPCp8',
    'ee30zvqlwf-f'         => 'AxkV3feSAQAAaOPuykSgKYFjYuPx8jZgfWoArgvPaMkq_J5gTHu6sHTf2OJaAWOiD0iuct3FwH9eCOfvosJeCA==',
    'ee30zvqlwf-z'         => 'q',
    'origin'               => 'https://www.southwest.com',
    'priority'             => 'u=1, i',
    'referer'              => 'https://www.southwest.com/air/booking/select-depart.html?int=HOMEQBOMAIR&adultPassengersCount=1&departureDate=2024-12-24&destinationAirportCode=LGA&fareType=POINTS&originationAirportCode=OKC&passengerType=ADULT&promoCode=&returnDate=&tripType=oneway&from=OKC&to=LGA&adultsCount=1&departureTimeOfDay=ALL_DAY&reset=true&returnTimeOfDay=ALL_DAY',
    'sec-ch-ua'            => '"Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"',
    'sec-ch-ua-mobile'     => '?0',
    'sec-ch-ua-platform'   => '"macOS"',
    'sec-fetch-dest'       => 'empty',
    'sec-fetch-mode'       => 'cors',
    'sec-fetch-site'       => 'same-origin',
    'user-agent'           => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36',
    'x-api-key'            => 'l7xx944d175ea25f4b9c903a583ea82a1c4c',
    'x-app-id'             => 'air-booking',
    'x-channel-id'         => 'southwest',
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
