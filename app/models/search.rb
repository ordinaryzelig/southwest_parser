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
    Rails.logger.debug '***JSON***'
    Rails.logger.debug JSON.pretty_generate(JSON.parse(@response.body))
    Rails.logger.debug '***JSON***'
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
    'accept' => 'application/json, text/javascript, */*; q=0.01',
    'accept-language' => 'en-US,en;q=0.9',
    'adrum' => 'isAjax:true',
    'content-type' => 'application/json',
    'cookie' => 'swa_FPID=1baea91b-2baa-478f-bcc7-8432e2dc85f2; akaalb_alb_prd_southwest_spa=2147483647~op=PrdSouthwestSpaV1_lb:PrdSouthwestSpaV1|~rv=93~m=PrdSouthwestSpaV1:0|~os=6ebf11227eb877b88e3cfdc68a3ccb6c~id=2dd355b5ae8cc6062f612e44cf78c9e6; at_check=true; AMCVS_65D316D751E563EC0A490D4C%40AdobeOrg=1; _gcl_au=1.1.1459338371.1729283903; _cc=AR%2BraTHDGMhsU6B6hIyPNiVT; _cid_cc=AR%2BraTHDGMhsU6B6hIyPNiVT; s_ecid=MCMID%7C30842930538455691923305271868965195084; s_cc=true; nmstat=af429810-db06-859c-64f7-d114e26a653c; _mibhv=anon-1729283904697-9519310977_4971; _imp_apg_r_=%7B%22_rt%22%3A%22DQclZ69jgibf8CmquRG%2Bn70wOeCc3SC6wEwExzGyt68%3D%22%7D; _up=1.2.605229068.1729284019; valid_promo=false; akavpau_prd_rogue_api=1729290465~id=10c3957096038af2ab0f4f03f10587fd; PIM-SESSION-ID=zg7ArnierJrO7e7K; AMCV_65D316D751E563EC0A490D4C%40AdobeOrg=179643557%7CMCIDTS%7C20019%7CMCMID%7C30842930538455691923305271868965195084%7CMCAAMLH-1730240452%7C7%7CMCAAMB-1730240452%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1729642852s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C5.5.0; akavpau_prd_non_vision=1729636253~id=77ac02308c2e647fc60918a0e8cead13; akavpau_prd_air_booking=1729636267~id=dbc8f19452f3536f94557f42fa545b30; gpv_Page=BOOK%3AAIR%3ASelect%20Flight%20Page; ADRUM=s=1729635808340&r=https%3A%2F%2Fwww.southwest.com%2Fair%2Fbooking%2Fselect-depart.html%3Fhash%3D-439477829; mbox=PC#34106990ed8145df8a06aa81c5c675fa.35_0#1792880929|session#d0aa7b64ae864794857b96465fbcfb01#1729637989; _cc-x=YWNhZTM2ZTMtOTlmMS00MzAyLWJkZGMtMzdhZWE3MmU3NWYxOjE3Mjk2MzYxMjg3Njc; __ts_xfdF3__=550282641; sRpK_XA_swc=%7B%22c%22%3A%22TjhrczJ1eXF2dkU3WEpRWA%3D%3DRudVGdfa--YM6zOHfn2uuZkvucgfovYZt5FmFIFMiWfFvA7BJ2uP3xX4Ow9g4R8zT5RXtA_fMrctIBb0S9-pA56W5s5KfCwsdzy-knC3UE2vBbkZO2DKkwT2-LbVtmWxo10%3D%22%2C%22dc%22%3A%22000%22%2C%22mf%22%3A0%7D; sRpK8nqm_sc=A6hJWqGSAQAAlsxnMiHAL4JPvKjd2-5bwa4Mn7YHpx0HDPGzMRT0zjF3tJ2kAWOiD0iucqPJwH9eCOfvosJeCA|1|1|ad212c532b25d1d690dcdcdd6b614cee19b90e21; RT="z=1&dm=southwest.com&si=94d7db28-3d04-4b2d-a018-ebada5bb3080&ss=m2l0eqn5&sl=3&tt=575&bcn=%2F%2F17de4c10.akstat.io%2F&ld=a9aj&nu=114i3emmh&cl=ac79"; s_sq=swaprod%3D%2526c.%2526a.%2526activitymap.%2526page%253DBOOK%25253AAIR%25253ASelect%252520Flight%252520Page%2526link%253DWED%252520Dec%25252025%2526region%253Dair-booking-product-0%2526pageIDType%253D1%2526.activitymap%2526.a%2526.c',
    'ee30zvqlwf-a' => 'Zna2xyAgF1nWp05bZNCexn0BE4KVzujam0u1T6N98DbfRxOpWqstn=nwWUSqQx4=ghrpj1QI=JSx07_xSUpcX_0SIRjwLM1TNKST84Hx1atWbuQ1lVTesa4it8VA35JOC=la7_bEaR1-R6Agh8Jl5jSArGAjpXVpqW5TEuHDK48cjutPI2MmwgLlhp8WPFDMgm-xuUPg5-ovRDbb8FZvTpllyaKrjw1R36n_uawLT9GWem_C2UolVI6hSK8wdltPJgZcLTm=KsQsPwLzSijSqBigg3wjfqHAWRrWnQFXpKd-MoQa7VG2CU-OtL5RFs0jgE6PM-G3zSnfXHqPaylLF0OA9GTBykt4sdWs_c8Z1V7V0Q8gtMItOmBI617Qq=DGQyfMm=7cR47uFgVLc4Z_lTJqgXkio2=4oxb18Npk=d3_EbSCCE8v6220WA1FbmtVBEPooJGBfV=P-t5tqp7KHxmCV07OXHB9nK02QT5s8PzVwQh-rXdCTb8aZmibR3ZzeIAiSqjzE5A36DE8foznPmpJhONkibZcPXECfzf0ZARJXA5W=G2kJmsQ8H6XCBGm7Aqa11qjRKsQ1vyyy==HTWWFJmpULqJgZ6F3c7ZkK_Stj1QuuTkGmiuMNeR3ofvsG_4oB-oeTwNHsW6ZVCMkXUssZoo0pyJi6ONjWV7K54-ARhPh-XtfQmo8W9lm2OpsVICPZ37KS=VfzEgKl3h5qipKjPET893zaqdi2BCzyKujGEcuPfsHlMJzVd_sMg819WjGA3ocgtb-HmMqNfqinqy3KnXJzqVlG345zrV-QRjfLAayut4sFeavMs8xm_6N13RytG_AOzWawN2hVndrFkLckn343u81cz4_pcs7CUDjvgtnPH-rddGnFXOHd9mwGJx=ff6QWfPguvb_bhD4fp5Ln0tnFoaFFRItkCJU4=5ymtC6SjepBDa8tDZ_WqUh=M_MPVOM0M6G9sv=z5i8vryACjkstP=iw83iFM9JhSgmpz5K7_qnstf-IUztAadrifjgBihAiPxTX3IjiRBHSFUbZM3ml6Qmf-xREu5I3hnl=aDEBKeQ5ENfa_wyuZOD==U25ei0MzvDKu9yXRz-Oz1ni7PgxTicJ_T2S1vR5CHmiJa7OOvqe0HNHl2J2T3dvOJEl8fEP-4cLqvFutSNdKzs3JVHcTB7OekerEMCRM=VnBDScjx3DQ7IL2kGcvHVpzaK_gpFFyjD1ZF2vpdXpET9LwEpNNHvu9h3InnKn_gxDfd3Z2llsVT2-3ldV=d62q7EbMNWMs5obE5chCWtzQ4TEgPh3Wc68svkdncBj__mczeaZCVv_kkAo0K6eomwU_a0KiMMn0gWsU=CmM-zRqCV7dwt6nv8jXMApJ1tdKw-rAMx8Ag2B7c-lnbMA6KLStmQPWHmcCg8mWlNt0aN_5PLpbQFS6C-lJ-mRBBF6xVRun4rx9qfGuef1DmLOTZLpoNhLj3xDQvWxDf3VgiDd4ZadEB5XSwAX3=lkwoGJdlAqHLyHAFWWbpmqrGoMsexyaMRWH1cS=I8nGZIgvNGA9f=Np7q0cmZRA6WwSFGm-0BbVn1e0_u2BuiJ34UTTud4itTPjDi1l0egxRinUFDDC7FSMjwpd8PGdszb3rmlvLWhnBnBCfExge0-r_WTL9d4_UZQfGD4i88tGR-8Z8WJ=pAZquKPJ70whlNVHCP9L-==O7ghNkwVsg0Fm7w35Nr_6aOxug0Xl8B=FKTOQ6E_PA14jUe20q8hI8fQz_Lh_4kThq6tgBK78goaJ4Hf8Q1kaRvi0RtBm=bCMsLJvue1zntmqmZPM5IQ33HFqoxo3IyBEwridBlajkW0FI=8rZC52SQ8X7fSlGjDCDiSx3DH3OAHbCkU9Go1m=XgkrGkqCcANzXCRRp2Nuqbriik6E066ND6r7Mey1qdbFMAQOtle3ORAMu5l5L1Ko6nvWWHq5lggVDEmxSHUhAOZVWG_pNp-m6GberWwkmU52OI6Sxzu=ULOa_N6ujIa-nM=vHLx0MwGZCKd30j4=nU-M=j14v8GZ4djggz0HXUrt9OlltmSvyE6KPQK8jENFOMFE9ITtboBl0-KhICsWHmpxaaDqsV8gXKqtW40E-hircinj8MzB6FiCHXkN409l571KFP_xTPWeWJ7g0lyyBgH=DDQ6MEFbLzPbDa6RdAWqRaIB6yO9Ojy-VpWVriVsWO5jdgJF2izubvN1do7=xKtb=UoHe8diyIupAacvzxStww2P0dIcBNtHE=-4KgpRQGCNcc_o1xmXs9sT1ZzfPqBfkVz=Vj-nLU6RvpvSzf088-3B4gQ4wrPi6D8hVTI6RfIupV8FwrCVIJ4G8q2VrD8XaJvih8=1hpICri=jo0IKE1ZDNjmx01RoCvkv2BxwEZo30UF=3i-FF5_MJRqeoktor_FySvmaB39QAF08KZwcUO3a8npPh4saio76r94WQili9KN4mGUuKB=G5-80tDlFZ8gLB0kEUhSj2h20hz=3gg13pAEp0mpcbBv=lZZ00XVnmT-PyJrP3F8NEgfudXImRu_qZwU6JF0hkfHArVGstsQcRcwXC-k4NuWEEPg174EVw061vF2vJr-HzSqSbV1hdizRbhINw5f9qNXkj2ZVkKEWisR8lqzXRx4WUgvOn0-A7lb_u5tIKygTtCGmTZi_dtT6GCPoDNB2KlvGf4yLHk0hnM8N_9c7=7yACr=oGPAo32KP7W_9FJLhvWcIBt=vtVJjzOefHjKoN=WN6pSMbPm0Rc1eX0CrT3bhWXqDeP3epklQvsNrWfHWFw6wWaOt5=4aUUKNPoPhMeKzem_vuppBwHqCRuaO0Bq1F8FFkqELSWk_NUi6H_lwttwMbEAbF1mLaKmH1ZNhi_8ecLqT9mA2AfrkclmbjJT1G5ZQQP0Ovh3nRXSBIPb3NiTHmMUs8lkxZgT-f5wpXWxhWpVUC13l-eNA8OFQGlOKPDBXXSHOOR5J=w6Rw_MhhifFkemy_nUWeqCF7Q2NU1kCkkaUmrG52pz8OQth-D1v2F8jW7wPiAW=dlrKGUClWyFUC1gR-pA4mllrAoWjp_bg=0ZCw8sy7myiJtQLaGsvBdZ3OHAPUgDZlRDUiAMmjwCswNjENab=J_Z3uuMP=XLcu7v80XAhPn2lKPlPB0tO4plC-smispoTm8zarredGwTtOZFapQE5G7QCNEkN77yfEu74=JjXfX6rjZ=KQ3mQgKn6fcXuFG3pQKk6UfTuxCECx1Zkxn_tMB5t-WE_xwmW4h7OKyetDeu=-yNT_pwCjVBBWSUx2P5aGSZHyS7sfZVvmhG4rjqd3NRBJdxzh_VyUMFlkFxRj76-5hgExMCfQbXwNdQgyNPJJ8DVKBHClN0NBSwHWajcvk3AQkSnSznkBTB8-wwmgbC-xzcrsLHC=KwEOAcVWB3fcBKSC0qlP9Nr2JJx19opwGGkT2BqKinSIkBzOMt2bRV0lnLR5TBXKqiHUoXKoLINb3Xqgs_O7==ZZpnKznlGN0fSMJoJtCtlZ_Aj9myM-VWrmOggxm3=bnGpU8=aUKaCao9Ev2wu0145m5FwMX_6GHpPepMMxXgH51K9pxMmN9S8dTspOImaOs4UZM7r7gfAMM5uj5Oct7Z1RBoWSLHwSQA_LNfEUq85nG4MzTx2-bTbubbdJaS68oiKTzdf22M5vJAQ9QhbEfcCDpuwqzP1=ysdoilr3RucPbj-lw7S=HKshmHiZBVEUnpLhW18MT75m1l8G817VqLJaBmefOVUa4AQRAIabF7rADhJbmeFqVpUID_DSz-T8Csii-HovzdBIah6wJKJZJVGCXX=vRVtMcbs11bdSzK0HXZWc3LEH_J3R2LiXPm-4kNMzz7lJE4ERya36c-S8BEOr3IkfZpMEXa7xsuXL20OQ0DZ1mja7wFM4cy79g6fsalBUOvM95Wq1lO=1eis9VAwGFtBA-Q4fue0-kfR=KP6eq3uL=g55kaV5wj_7_HDMMvV7H7kPButPP3uVkSN=_i0ech1hcKNrUH_zpfqWUtN_C5VPlKyDrjZN=ACHBSVkTbwBwTraTjac180V_IoLzW5Txxq7FtBErMnLaQ0kUHti6wRjuuoe9HFMlZwKFJTfSqAD6nV127fQa2sXQhd3gnELFWySt95TvX9cinQ12ACoPxe_JFPW6ci6oEr1XmzDtrN7ROtFDGu_4Cx9cB3lnHQNQ2NZ7MfstqwkSI8aDX6uiIXxhl1VgCO8KvKWHUFtW=Dle9iJDW5FHczB2rI68E-9UCAwxhwXcGha8C7oSD0ssruq1qsxbeAadTjrl3yKzwgaB5VA8NUeJonIePCWf88N2waae4ruawJw=-8m9hXB9-fmkOH=2kH6HLBVLMouZmKBi0Q39f6-Uq8BTciHMvrVp-wEOjRJmPXsxP4fMq6tz_dDXOqKss45nUF5qh0HI010z8P1QZeb830JKErVsoDUg7G9TVVXCU_2jGVZxn5L=Qvs13x57oeaM2EKsw8us3nX_xBJoax5AoF3xbDy9EIIc5KO9SRvn3tEnS-J=G-mwRKyHPU-G98KSsxo5Gebw4Cn-zUwXj8TSw7gDmvIDhEssWA4DVdXNOmR97kWQRmX7RwCeOBEOZqQMPb0N7FR49HD-3b7HPQwzUc5HlHZFA4e_=-rD9GE7LxgIs94F4CZSC3xo1=omOuWunB0zxygZC8rDlAQKJwMjpHNig6C1pc8BwhlPs1L9yi=upMS9Ajaz56a3VSoLLBvgJmekqvIm4QHzWnRH=OkXI-bJNhM_6Rc4KdfVp2ESwe8C_z18dpEkL5gxlNq43NXZQ9P6cMS5UIbNS02FvxW=vfNJNaz7GIkH=P0-=qzlcZzuL2=zkBPyakBBmRA8ql2nybenPrSL_cTTDNCC-TS8WG7HNG8kUNuiE15ByOfsbEyavKCmcfDC-4KsNLksm8pm=2JVG8knjQooE7j4RLwDfXQPoQX4D9QypgwjSbggRpoyPcxfxIRb3=-Erv2QrxV-2wvRMXP8AaacVXoTmtpfh3rg1HcgkVhFn4dkAkWKePHvpgzT8w24U_r4b-7=6tosA3o5rOoPnmlfiiASZJWtkJ295t7m=gqS7WV4NkhKKTCfvkep3zTs9GbWOxo--U=ADXQC2bjPuFhPvJBHJP1GdGdbeaBimyp-JqPRynn891W0cGUie=7BKei5K5AXBHmWOybjie=yTf7nBClWPczSpGo1Fcg9gzkbRAU0I0NZElBzdgRSbbV43yNMJUJsc51Up0Xsjqv3D8rbBBqmA11hNFjIpHfmqqz0Mh6yMCJrg1nZK0Tfs14qN4Js=yrISpy2Wt4tfrpNC10hIXNdnN=QhtNqdXy2f7kv-viz1CZDT2o5V-RXLK-jy8KDPK2ebrbAIfxnXDnHQdZtJRVCFKhTaKdOH4VjaVctbFCRGa_hhWHagU5DsPWkkNQrrIQ7BSm3RlZcmukjmXuDWTNDPkOy683HiyBlOFvFEwcGF_rEBP9w2ZRbdEMu_Z4PQUS5EBDzQANL-w3RWm4g_iDxbw43hd1WgnibGk6UBUc82Qkh0wMVcsK6aLfmPiQScS6pwlyx1TRcnChz4qS=q1O3eTgDSNNjoLnfc9i8Rr9gu676ObVhs2ChFo84tFJi9d6W54CONIR=k2NKb0FtP2f7xRMNBsMJK_ufg3g8tde3W0L10xdW90k8k_pxDkPZxaliMW2na0afs20CCHe1PTrjIQLx0e8OLKDEmdt2UiyeiJpFxxsV44oN363rz3F099DSa55IxaEuOeE9ORjcqKd9K2fxZTVBzM6wT_yUN94v9OriItNZi7JbjMO40Kk_UFjCfcwu1t9czua-nt4EtkOk3jOJNe8Ovhho3ZgrSOe-1rhcddJA1eE9Qkr4k3IwpMneZjNr4vR4Cx5htozrV_0IPuLihMHl2op27-=jRUsmxSVmmpr0F0LkU20x86OsqUd-qtFOyhTDotrRIx5f1pm4LmB2ngmziynh9lXuuBECZ8IuV527KZNJjfc27oBPHyu6QhD-mvBISF9Cj1N4qKmlGWRKAAdW=59D1-kdA0HkDyVCxRMwupXvkC9zNCVclpedjsRA5hVc3w80rHficEw3TUU_aArVl6kWXsnaQeKi4bnpZKQXLMv0WkLuLX42JW2WD7VqKcyCzs4X567=n1OBjSanT2PWHedmM=erjjwtrOwBfaqkmrNK8qyBv28XbDyfH1pzLp9qo274vuVRVcvIPzQHX2EHUcI1niFzQaPsODE6m3iTSyL541NtAcna6cA1NUam4_P-L95BH86EfnesrhUxWNyoVPTb8TB=O8bcvo67KQL7rB0_HX-qRxlVMABXEwHAqs0PEeg1g7XC9FNWjAGODWNJmgjo5rs4Nc5GWTQEy8Hs_VqX1Kh-w8aHry1IGdQ4Wt41qddVDvJ8HC_w1-VbSzJp24-4oGZsBccaVLsXtIFlK3RAIhSQn-ob6eILvzuNIRNLHMCa_u8hxG44OF_RuptEkb24LKbUAm=uTfNNLsGzNGMvPzLqb=pdjLlede0HazetgpcSu6XzNJxShUTS7DTmW5JBj=2Jieut0CflvDVOroZnIlKbuJo6tC_Jw6iqFPCkrdneg8J5PZqicqz58wUO_B0qnR8=PmIc7F2ff4=WcCjXNyJAelDzrQ1ayWna0s=o5-lTzA7MoM-iLRsx_=JTgMRMglfESB=JwJnn6P7J07wUFqD2ufkwfcEVHvn6Xfg_sMLxG-Io3aSP2tN5nnwQHX-zX8O-W-w6eUXlp-jSLyO5U5S5AfG6eu2EcHG-16o6_k-4fQRkVF7RvC1-LNskzu4v=ilnbjQuN1St-r3VHa44_Hz8yXtNabx4myLtkloCx9idC7U3HGA8XkGUcKJOzPbyt9Oe6aIiON1oe_I7=AndV_bvNmKZCbnEW6apTtl9PFZW0h57yW=m8KJi1REnr=WGLeBpHA9M3Ondasskauk_turWJjy-F_fjFWs_qJ0EQhWv8F2czjI_7gMHzZB0Ln39=N9ofcq_chhQ8TTVIqcvJ8GxjA9dFUtGeUR43tEXmgcDa0uXi=lgQbPlxoSSsj6hBzI7QNZyqg5=ub-WB=l=jyBPIePIwpSermlEWvMQRjGpfiO6HxaRTCbaPBToSX2pSVxGaae09gsi1tvC5=AyGPjg1OJ2KbftK8bors_sAIf-y4tg=EoMofrKP_kbhiH_yhRaH0l-o_uNC8H791QCi7UryM2hC-yfbLmNBI0lp0A1Wi=dZrnaNTk6xk6zDCmMGqg7lZ5GOCXk-dU3h5PKdsV9ig=Oqd47FjUj1UycG6FZNIKGp0zSVMp48zW=dbrHVW9u6CFxd2NabzNZmHjtm1U_1cD7H9Q0CHCN-cZz2id7d8mk8Op1H2WM5ONwN2o39kVpK5Cl_LK4=8rGBvQgDM6FA==Gy26zjB6Q6M6yB-HW4MST5u4gGLVEZnTlePHu-jaLLDH6_Qrri3ogQUNpuagTB0n_Fi3jC=D-yfRmIx=gzt=rxOtgVj-yDeKujnTohBqHtdP8CduJ_S_boK_aqmxyZzGA9BpBuVth4cgHSi9fjeAsjFJ58wJETNsDu51d0PBv0IGzOPsvrwkEOwV-C2bbExcIfHGUx_XAcuI2_5jPF_P2EBj5yH-a38MwFRE0M1Kl4VQwPd3wltOTzK=rqlavObcvLlJ3-E5NR1OEprZyd9wxwnQOqTlSc-zgMzowKhyp2LILVJoLQWVkDLL2hy1SMmVcRI1ULR1It4C8KH5pwKw=Z2n5XW-LddajG5UbkPnQyGTWslZoJnkqRL8_bBnD6pn2LOzDRuIvUUwQ7Xj_CcJVp3M3pXULhc0NmWxAUi_Krg24W_cr2t1zSB4C7kAUwLUE8-cwgz=Gx2n',
    'ee30zvqlwf-a0' => 'JtBAWkRFDbE39RgSZ3-MjGp3znfXqrFUUbq4pMKANTPhzfQig1qhM-O_LItUKk6qhrylii-0769nyJ2zt_NVnUSXLp6lgkVchkaUL3U6FaZR8WUhvq_-l3GgrTp2s=djO4H6C72rUDokRgBK5ZyVhobeZFlFzgMFTGwHNnz=m_pMjDzxTIXm8iDrDUuIZ0eaVzvRt0HF7FqObZnLiQ=bHv6NR6X-quRcxx8LjAT3BAZjeVe8_cZpOzfK1sCMx_9aV2PfhcaPeQNMgiHiarjnNf4oTd2Av_aG48OBmL8dKdB5Rr=nRTeW2fqNk7aZ9VJp0QXXBFPX6NbU9S8A4fGziFtc59i5besRudiWHg_AX_ALqHHk6K9=gcGxlDyPPaHCmgrAKrazX2Ly23UKOMo29IBbZDPfqeLhgT19fQhQ269VHqJ6',
    'ee30zvqlwf-b' => 'p1cc5z',
    'ee30zvqlwf-c' => 'AGBaVbaSAQAAwNR6dVRgialOa8EsukkjdfQGF_5LQZ-J7DLDL6ha3kTmZUCr',
    'ee30zvqlwf-d' => 'ADaAhIDBCKGBgQGAAYIQgISigaIAwBGAzPpCxg_33ocx3sD_CACoWt5E5mVAqwAAAAAn36CjA15sq5pv2AC5JTrdk2x4Sec',
    'ee30zvqlwf-f' => 'A2vUWLaSAQAAXH1A1pxj7-U1Toi4tJl6TMB3Dh0ssiAvUR5vQFirGep8U53ZAWOiD0iucqPJwH9eCOfvosJeCA==',
    'ee30zvqlwf-z' => 'q',
    'origin' => 'https://www.southwest.com',
    'priority' => 'u=1, i',
    'referer' => 'https://www.southwest.com/air/booking/select-depart.html?adultPassengersCount=1&adultsCount=1&departureDate=2024-12-25&departureTimeOfDay=ALL_DAY&destinationAirportCode=LGA&fareType=POINTS&from=OKC&int=HOMEQBOMAIR&originationAirportCode=OKC&passengerType=ADULT&promoCode=&reset=true&returnDate=&returnTimeOfDay=ALL_DAY&to=LGA&tripType=oneway',
    'sec-ch-ua' => '"Google Chrome";v="129", "Not=A?Brand";v="8", "Chromium";v="129"',
    'sec-ch-ua-mobile' => '?0',
    'sec-ch-ua-platform' => '"macOS"',
    'sec-fetch-dest' => 'empty',
    'sec-fetch-mode' => 'cors',
    'sec-fetch-site' => 'same-origin',
    'user-agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
    'x-api-key' => 'l7xx944d175ea25f4b9c903a583ea82a1c4c',
    'x-app-id' => 'air-booking',
    'x-channel-id' => 'southwest',
    'x-user-experience-id' => '82088716-52b2-4ed3-ad29-a8887fe29a45',
  }

end
