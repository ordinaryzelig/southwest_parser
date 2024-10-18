require 'date'
require 'pathname'
require 'fileutils'
require 'open3'

curl_template = <<~CURL
curl 'https://www.southwest.com/api/air-booking/v1/air-booking/page/air/booking/shopping' \
  -H 'accept: application/json, text/javascript, */*; q=0.01' \
  -H 'accept-language: en-US,en;q=0.9' \
  -H 'adrum: isAjax:true' \
  -H 'content-type: application/json' \
  -H 'cookie: swa_FPID=1baea91b-2baa-478f-bcc7-8432e2dc85f2; akaalb_alb_prd_southwest_spa=2147483647~op=PrdSouthwestSpaV1_lb:PrdSouthwestSpaV1|~rv=93~m=PrdSouthwestSpaV1:0|~os=6ebf11227eb877b88e3cfdc68a3ccb6c~id=2dd355b5ae8cc6062f612e44cf78c9e6; at_check=true; AMCVS_65D316D751E563EC0A490D4C%40AdobeOrg=1; _gcl_au=1.1.1459338371.1729283903; _cc=AR%2BraTHDGMhsU6B6hIyPNiVT; _cid_cc=AR%2BraTHDGMhsU6B6hIyPNiVT; s_ecid=MCMID%7C30842930538455691923305271868965195084; AMCV_65D316D751E563EC0A490D4C%40AdobeOrg=179643557%7CMCIDTS%7C20015%7CMCMID%7C30842930538455691923305271868965195084%7CMCAAMLH-1729888702%7C9%7CMCAAMB-1729888702%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1729291102s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C5.5.0; s_cc=true; nmstat=af429810-db06-859c-64f7-d114e26a653c; _mibhv=anon-1729283904697-9519310977_4971; _imp_apg_r_=%7B%22_rt%22%3A%22DQclZ69jgibf8CmquRG%2Bn70wOeCc3SC6wEwExzGyt68%3D%22%7D; _up=1.2.605229068.1729284019; valid_promo=false; akavpau_prd_non_vision=1729290291~id=5049ebc1e1cfc80de5927c1810913cf2; _cc-x=NDE5Y2M5NDMtNjA2MC00ZWYwLWFjOTQtZjA3ODQ2ODhmNWFiOjE3MjkyODk4MzMyMzQ; __ts_xfdF3__=137222312; sRpK_XA_swc=%7B%22c%22%3A%22ZnZocm9MTWJpSkQyY1ZMQg%3D%3DVPZNmJG7qogWmNor1uJ11ThfXv0qOQJd1ccRtHKuRMguXGAuC2PnUwPjeU8lLESfO7fu8WgiMh2wWP0R4TfoRq2gsVHTbhUahVpPqpT_5CHS09cjbs501MY4mF6inppppz8%3D%22%2C%22dc%22%3A%22000%22%2C%22mf%22%3A0%7D; akavpau_prd_rogue_api=1729290465~id=10c3957096038af2ab0f4f03f10587fd; s_sq=swaprod%3D%2526c.%2526a.%2526activitymap.%2526page%253DBOOK%25253AAIR%25253ASelect%252520Flight%252520Page%2526link%253DLog%252520in%252520Opens%252520flyout.%252520Espa%2525C3%2525B1ol%252520DEC%25252030%252520OKC%252520LGAModify%252520Select%252520flights%252520Depart%25253A%252520OKCLGA%252520Oklahoma%252520City%25252C%252520OK%252520-%252520OKC%252520to%252520New%252520York%252520%252528LaGuardia%252529%25252C%2526region%253DBODY%2526pageIDType%253D1%2526.activitymap%2526.a%2526.c; ADRUM=s=1729292107334&r=https%3A%2F%2Fwww.southwest.com%2Fair%2Fbooking%2Fselect-depart.html%3Fhash%3D-608585337; akavpau_prd_air_booking=1729292707~id=51978917f42678185adaea28096e1957; RT="z=1&dm=southwest.com&si=94d7db28-3d04-4b2d-a018-ebada5bb3080&ss=m2faim34&sl=0&tt=0&bcn=%2F%2F17de4c12.akstat.io%2F&ul=1crm6&hd=1crnz"; sRpK8nqm_sc=A6hJWqGSAQAAlsxnMiHAL4JPvKjd2-5bwa4Mn7YHpx0HDPGzMRT0zjF3tJ2kAWOiD0iucqPJwH9eCOfvosJeCA|1|0|99ff20e31d3d6bbdf624a73fc133e85728befa29; mbox=PC#34106990ed8145df8a06aa81c5c675fa.35_0#1792534701|session#fd3b8beccf0d47c783bad012e00e0ccb#1729293968' \
  -H 'ee30zvqlwf-a: X29VteCG=_sMBJR_OEmxRlJlQ8WgWY8PNEGmWc5ZWqLBPZuHkEvain_N_VsHmJOh9rkwoAogkybeicVu-M7s=b9oF9Ehq7VuzgwEv6FP3UvLghebfJLSajrabkXk5hOnOCT6ABk-j4ZJ9Ql1Dem92qAAcgmoujxDmnh5PtPBcTHR7rJ1kzcyQzgx_aJEAnui85mE9gOL_ah0zHCdhgn7ftVakQsGx_yF707yZF2W=9UdUMGq0uMFd57fzSGLVEl=baPhdN54q894_L8fTAvzV_6eIywUW4I==F-mmk-TT-xUBrPFQD91eY8D34vcTcCcN0y8L6C8aVV6Tl7nkMDdoxfeErbikX3y07=vzctMb6mcu649g1jU5=Q9SFUkbt=h0n3xDd-Ed-WYijV4iFZxhfQa48f-NR4g=lxJsCTPSW93xDMm0td9ZEQbAUVDMOMNNy6Umbn5-FFbLeVAVh=UO31qizs_Z7wrNnnRVfbVJxq3=9JibHoidzuPQndClx8qTZJyxZJWAEiv-xfxeZjF_BHZCv6NynXsORxx5S4feYroheCslVrKzge3fjnj5-EYgohnMl4DOjmgs3_9CGDDDiavC8vBROTRWt56v1dY77XNEZ5Q3AKdRgqXfAwqTxl_Bot1BIIAoRcxE7FHJ6kO80Lny=EvwqDdl70i1OLZbxVlxz1tfvCJw4lODdZ9gDzaJKwQLsr5VV5zh=C-21UwGjiYlbLc7A-ZbmrmzQdq=bh=TOs16CXNWsqAKBNZCFDPPn30H2JzZlLLojH_0qoAa9BDDucwQ=ntb0=MvNfGo97m2kIjZDEQEhIFesnjN_VLiJf=XzLhZhSwZTVgKeW6UJ7rNZcRBtwcLNduDf6l-5LgER6HT5MoIVYTwjJjwTq5BctTm5FPRnYgjqrfaf5WcA8_ushgTjflwd7XrWNiFZG1wFkatEOX6Aoyi3fsHbY4K1_0l96z4Sx17ioaVP-OE4qWkEcHWGf0LxBGDqymzYxsvNzUsjK8CugC55ByYced86ZwOvKzem-2d0bQ59nomIjR2eKDATO=ghmlsAcJ0Kc5QPuXVPGiEyKNfITeqbtMXMb9l2JzZhL4VvlmoWX9Dr7Ej-4dYMUbQxBjiWWJxhTalbIRmFcaELo=LbOHNJgZfBToR_nLb0o0-bDbzERJMJrhoTebLQkMWv6Zm-7ghL-=JmLBhAYKgeSIoNz0XP5_RXK3os1q7WW1UbfGJzdZZj0TF3bizx_fbciADRWQdFkW2jlWK1QO8JAULoQzUEskarN3ET1jPWONWWWYQtjyI31leW1Kjn70OiADry=MkT7PHzocb1n7g9z8Hd6YkWExqcDMz5EqKG4iNZKAd7z5TdTK8VQUaNaWRPKmX15RD2VvbdSjCtAz5Yv6zyimIHF4qQJzb56ZScT1h2iAudaY71T8XmKKdeobyEvBy6acUSzNWf9stLhGhBMNux2K-sZbkoZcPXaYA_VSrsRJI5hv5cMzXQzeI5-RHTre0owy5zbOa_ARmPZ06q9s_iqMJDEb8sUgbK7Sil1LmUKf4hkDPtRAzcKj_fggFi4_x1A8Ue1035hOTw=b03XNWYmfaZ8Vt6kH36o7rfD0IwejELaLoZLZsZfeVfOwZoWHrCtRQjXVGiqVZMNzF2sXVx9T7tw_kYd2GYWvmdYR-9=iLD26IxMXjuEkxTw9xgOTdI9TDnftg5weCo_qOZkyLzzyI0j5DLPSYdXusSjUcQwfTNoMeUG2S=6OyH4=wH5WJUYj-ZlPjVJGa1ImRya=YmavDgBsTQvcC9vQNyXw6WDV-RMuwA9PGU1bYXvVskE_UH3tHVXHnEtLtkew3FnoEk4KtFebZQGE6ggew2MTIUc8INRGg6SJ93b0aQK-r0dSygMDen3DURoeyTJfNBs71zt-wFCmAM5RV9BhecVG7OmF5M1xV9cQ68YtGeb2kT2SDoUQqTk=IsktN4SO7R0dY9=bhD7ZDM-DGaVvKun4AGAX-081RE532mKoFreO4O7L0xa8GSBfVdUi4qB4o8QNCGVUM39BcJEiXqEV0XFm704MW6u0Ck3A1FTI1gZUZAVM6f0xgBNdwY4XtBU7rXAsvus43B2Z3=' \
  -H 'ee30zvqlwf-b: -e8hjtm' \
  -H 'ee30zvqlwf-c: AKBh16GSAQAAUUNRZTiTnhSCJSJ_wmr_SWHByQAPmKTa6ogkFTs6HMB8pAZB' \
  -H 'ee30zvqlwf-d: ADaAhIDBCKGBgQGAAYIQgISigaIAwBGAzPpCxg_33ocx3sD_CAA7OhzAfKQGQQAAAAAn36CjA2WVyi0PNZNtsTbp-wxMYdg' \
  -H 'ee30zvqlwf-f: A-Z-16GSAQAAcaQUqLD-L2rvk39kFGDaiaI4TNe3dBBlSDjR649eZRk-QIRGAWOiD0iucqPJwH9eCOfvosJeCA==' \
  -H 'ee30zvqlwf-z: q' \
  -H 'origin: https://www.southwest.com' \
  -H 'priority: u=1, i' \
  -H 'referer: https://www.southwest.com/air/booking/select-depart.html?adultPassengersCount=1&departureDate=2024-12-30&departureTimeOfDay=ALL_DAY&destinationAirportCode=LGA&fareType=POINTS&int=LFCBOOKAIR&lapInfantPassengersCount=0&originationAirportCode=OKC&passengerType=ADULT&promoCode=&returnAirportCode=&returnDate=&returnTimeOfDay=ALL_DAY&selectedFlight1=2024-12-31&selectedFlight2=&tripType=oneway' \
  -H 'sec-ch-ua: "Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36' \
  -H 'x-api-key: l7xx944d175ea25f4b9c903a583ea82a1c4c' \
  -H 'x-app-id: air-booking' \
  -H 'x-channel-id: southwest' \
  -H 'x-user-experience-id: 82088716-52b2-4ed3-ad29-a8887fe29a45' \
  --data-raw '{"adultPassengersCount":"1","departureDate":"%{date}","departureTimeOfDay":"ALL_DAY","destinationAirportCode":"%{arr}","fareType":"%{fare_type}","int":"LFCBOOKAIR","lapInfantPassengersCount":"0","originationAirportCode":"%{dep}","passengerType":"ADULT","promoCode":"","returnAirportCode":"","returnDate":"","returnTimeOfDay":"ALL_DAY","selectedFlight1":"2024-12-31","selectedFlight2":"","tripType":"oneway","application":"air-booking","site":"southwest"}'
CURL

wait_between_requests = 10

dep = 'OKC'
arr = 'LGA'
path = Pathname.new('/Users/ningja/Desktop/NYC - HOU/curl')
dir = FileUtils.mkdir_p(path + "#{dep} - #{arr}").first

earliest = Date.new(2024, 12, 23)
latest   = Date.new(2024, 12, 31)
%w[POINTS USD].each do |fare_type|
  (earliest..latest).each do |date|
    curl = curl_template.dup
    replacements = {
      '%{date}'      => date.to_s,
      '%{dep}'       => dep,
      '%{arr}'       => arr,
      '%{fare_type}' => fare_type,
    }
    replacements.each do |k, v|
      curl = curl.sub(k, v)
    end
    resp, _ = Open3.capture2(curl)
    filename = "#{dir}/#{date}_#{fare_type}.json"
    File.write(filename, resp)

    sleep wait_between_requests unless latest == date
  end
end
