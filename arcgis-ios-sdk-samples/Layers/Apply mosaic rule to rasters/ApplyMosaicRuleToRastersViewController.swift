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
            // set the viewpoint to the
//            let center = AGSPoint(x: 11.858047, y: 49.444977, spatialReference: .wgs84())
//            mapView.setViewpointCenter(center, scale: 10000)
        }
    }
    
    /// Create a map.
    ///
    /// - Returns: An `AGSMap` object.
    func makeMap() -> AGSMap {
        // The URL of an image service.
        let imageServiceURL = URL(string: "https://rtc-100-8.esri.com/arcgis/rest/services/imageServices/amberg_germany/ImageServer")!
        // Create an image service raster from an online raster service.
        let imageServiceRaster = AGSImageServiceRaster(url: imageServiceURL)
        // Create a raster layer.
        let rasterLayer = AGSRasterLayer(raster: imageServiceRaster)
        let map = AGSMap(basemap: .darkGrayCanvasVector())
        // Add raster layer as an operational layer to the map.
        map.operationalLayers.add(rasterLayer)
        rasterLayer.load { [weak self] (error: Error?) in
            guard let self = self else { return }
            if let error = error {
                self.presentAlert(error: error)
            } else {
                // Set map view's viewpoint to the image service raster's full extent
                if let center = imageServiceRaster.serviceInfo?.fullExtent?.center {
                    self.mapView.setViewpoint(AGSViewpoint(center: center, scale: 58000000.0))
                }
            }
        }
        return map
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add the source code button item to the right of navigation bar
        (navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["ApplyMosaicRuleToRastersViewController"]
    }
}
