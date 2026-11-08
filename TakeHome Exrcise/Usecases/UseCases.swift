//
//  UseCases.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 06.11.2026.
//

class UseCases {
    class func loadCityDetailsUseCase() -> LoadCityDetailsUseCase {
        LoadCityDetailsUseCaseImpl()
    }
    
    class func findCityCoordinateUseCase() -> FindCityUseCase {
        FindCityUseCaseImpl()
    }
    
    class func getForecastUseCase() -> GetForecastUseCase {
        GetForecastUseCaseImpl()
    }
}
