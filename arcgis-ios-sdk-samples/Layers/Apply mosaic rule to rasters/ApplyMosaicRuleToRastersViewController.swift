// Copyright 2020 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import ArcGIS

class ApplyMosaicRuleToRastersViewController: UIViewController {
    /// The map view managed by the view controller.
    @IBOutlet weak var mapView: AGSMapView! {
        didSet {
            mapView.map = makeMap()
        }
    }
    
    var imageServiceRaster: AGSImageServiceRaster!
    var rasterLayer: AGSRasterLayer!
    
    /// Create a map.
    ///
    /// - Returns: An `AGSMap` object.
    func makeMap() -> AGSMap {
        // The URL of an image service.
        let imageServiceURL = URL(string: "http://rtc-100-8.esri.com/arcgis/rest/services/imageServices/amberg_germany/ImageServer")!
        // Create an image service raster from an online raster service.
        imageServiceRaster = AGSImageServiceRaster(url: imageServiceURL)
        // Create a raster layer.
        rasterLayer = AGSRasterLayer(raster: imageServiceRaster)
        
        let map = AGSMap(basemap: .terrainWithLabelsVector())
        // Add raster layer as an operational layer to the map.
        map.operationalLayers.add(rasterLayer!)
        rasterLayer.load { [weak self] (error: Error?) in
            guard let self = self else { return }
            if let error = error {
                self.presentAlert(error: error)
            } else {
                // Set map view's viewpoint to the image service raster's full extent
                if let center = self.imageServiceRaster.serviceInfo?.fullExtent?.center {
                    self.mapView.setViewpoint(AGSViewpoint(center: center, scale: 25000.0))
                }
            }
        }
        return map
    }
    
    @IBAction func applyRasterFunction(_ sender: UIBarButtonItem) {
        // Define the JSON string needed for the raster function
        let rasterFunctionJSONString = """
        {
          "mosaicMethod" : "esriMosaicCenter",
          "ascending" : true,
          "mosaicOperation" : "MT_FIRST",
          "where":"ImageType='Landsat7'"
        }
        """

        // NOTE: You can alternatively create the raster function via a JSON string that is contained in a
        // file on disk (ex: hillshade_simplified.json) via the constructor: AGSRasterFunction(fileURL:)
        
        // Create a raster function from the JSON string
        if let rasterFunction = AGSRasterFunction.fromJSON(rasterFunctionJSONString, error: nil) as? AGSRasterFunction {
            // Get the raster function arguments
            let rasterFunctionArguments = rasterFunction.arguments
            // Get first raster name from raster function arguments
            let rasterName = rasterFunctionArguments?.rasterNames.first
            // Set image service raster in the raster function arguments with name
            rasterFunctionArguments?.setRaster(imageServiceRaster, withName: rasterName!)
            // Create new raster with raster function
            let raster = AGSRaster(rasterFunction: rasterFunction)
            // Create a new raster layer from the raster
            let layer = AGSRasterLayer(raster: raster)
            rasterLayer = layer
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add the source code button item to the right of navigation bar
        (navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["ApplyMosaicRuleToRastersViewController"]
    }
}
