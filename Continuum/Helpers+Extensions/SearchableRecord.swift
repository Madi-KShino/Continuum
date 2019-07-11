//
//  SearchableRecord.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/9/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool
}
