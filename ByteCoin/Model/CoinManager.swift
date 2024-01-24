//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "202FB738-6FAD-4100-997C-9FDFD11E4614"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String){
       
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
       
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    
                    if let bitcoinPrice = parseJSON(safeData){
                        let priceString = String(format: "%.1f", bitcoinPrice)
                        delegate?.didUpdatePrice(price: priceString , currency: currency)
                    }
                    
                }
            }
            task.resume()
        }
        
    }
    
    func parseJSON(_ data: Data) -> Double?{
        do{
            let decodedData = try JSONDecoder().decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
