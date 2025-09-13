"""
Flask application for viewing EMODnet Seabed Habitats WMS layers
"""

from flask import Flask, render_template_string, jsonify, request
import requests
from xml.etree import ElementTree as ET
import json

app = Flask(__name__)

# WMS Service Configuration
WMS_BASE_URL = "https://ows.emodnet-seabedhabitats.eu/geoserver/emodnet_view/wms"
WMS_VERSION = "1.3.0"

# Common EMODnet layers (verified to exist)
EMODNET_LAYERS = [
    {
        "name": "all_eusm2021",
        "title": "EUSeaMap 2021 - All Habitats",
        "description": "Broad-scale seabed habitat map for Europe"
    },
    {
        "name": "be_eusm2021",
        "title": "EUSeaMap 2021 - Benthic Habitats",
        "description": "Benthic broad-scale habitat map"
    },
    {
        "name": "ospar_threatened",
        "title": "OSPAR Threatened Habitats",
        "description": "OSPAR threatened and/or declining habitats"
    },
    {
        "name": "substrate",
        "title": "Seabed Substrate",
        "description": "Seabed substrate types"
    },
    {
        "name": "confidence",
        "title": "Confidence Assessment",
        "description": "Confidence in habitat predictions"
    },
    {
        "name": "annexiMaps_all",
        "title": "Annex I Habitats",
        "description": "Habitats Directive Annex I habitat types"
    }
]

def get_available_layers():
    """Fetch available layers from WMS GetCapabilities"""
    try:
        params = {
            'service': 'WMS',
            'version': WMS_VERSION,
            'request': 'GetCapabilities'
        }
        response = requests.get(WMS_BASE_URL, params=params, timeout=10)
        
        if response.status_code == 200:
            # Parse XML with namespace handling
            root = ET.fromstring(response.content)
            
            # Remove namespace for easier parsing
            for elem in root.iter():
                if '}' in elem.tag:
                    elem.tag = elem.tag.split('}')[1]
            
            layers = []
            for layer in root.findall('.//Layer'):
                name_elem = layer.find('Name')
                title_elem = layer.find('Title')
                abstract_elem = layer.find('Abstract')
                
                if name_elem is not None and name_elem.text:
                    # Skip the root layer and only get actual data layers
                    if ':' not in name_elem.text:  # Skip workspace prefixed names for now
                        layers.append({
                            'name': name_elem.text,
                            'title': title_elem.text if title_elem is not None and title_elem.text else name_elem.text,
                            'description': abstract_elem.text if abstract_elem is not None else ''
                        })
            
            # Return found layers or fallback to defaults
            return layers[:20] if layers else EMODNET_LAYERS
            
    except Exception as e:
        print(f"Error fetching layers: {e}")
    
    return EMODNET_LAYERS

@app.route('/')
def index():
    """Main page with map viewer"""
    
    html_template = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>EMODnet Seabed Habitats Viewer</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
        <style>
            body { 
                margin: 0; 
                padding: 0; 
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: #f0f0f0;
            }
            #container {
                display: flex;
                height: 100vh;
            }
            #sidebar {
                width: 320px;
                background: white;
                padding: 20px;
                box-shadow: 2px 0 10px rgba(0,0,0,0.1);
                overflow-y: auto;
                z-index: 1000;
            }
            #map {
                flex: 1;
                position: relative;
            }
            h1 {
                color: #2c3e50;
                font-size: 24px;
                margin-bottom: 10px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .subtitle {
                color: #7f8c8d;
                font-size: 12px;
                margin-bottom: 20px;
            }
            h3 {
                color: #34495e;
                font-size: 16px;
                margin-top: 20px;
                margin-bottom: 10px;
                border-bottom: 2px solid #3498db;
                padding-bottom: 5px;
            }
            .layer-item {
                margin-bottom: 10px;
                padding: 12px;
                background: #f8f9fa;
                border-radius: 8px;
                cursor: pointer;
                transition: all 0.3s;
                border: 2px solid transparent;
            }
            .layer-item:hover {
                background: #e3f2fd;
                border-color: #2196f3;
                transform: translateX(5px);
            }
            .layer-item.active {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-color: #667eea;
                box-shadow: 0 4px 6px rgba(102, 126, 234, 0.3);
            }
            .layer-title {
                font-weight: 600;
                margin-bottom: 5px;
                font-size: 14px;
            }
            .layer-desc {
                font-size: 11px;
                color: #666;
                line-height: 1.4;
            }
            .layer-item.active .layer-desc {
                color: #e0e0e0;
            }
            #info {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-radius: 8px;
                padding: 15px;
                margin-bottom: 20px;
                font-size: 13px;
                line-height: 1.6;
            }
            .controls {
                margin-top: 20px;
                padding-top: 20px;
                border-top: 1px solid #dee2e6;
            }
            .control-group {
                margin-bottom: 20px;
            }
            label {
                display: block;
                margin-bottom: 8px;
                font-size: 13px;
                color: #495057;
                font-weight: 600;
            }
            input[type="range"] {
                width: 100%;
                height: 6px;
                border-radius: 3px;
                background: #ddd;
                outline: none;
                -webkit-appearance: none;
            }
            input[type="range"]::-webkit-slider-thumb {
                -webkit-appearance: none;
                appearance: none;
                width: 18px;
                height: 18px;
                border-radius: 50%;
                background: #667eea;
                cursor: pointer;
            }
            input[type="range"]::-moz-range-thumb {
                width: 18px;
                height: 18px;
                border-radius: 50%;
                background: #667eea;
                cursor: pointer;
            }
            .value-display {
                text-align: center;
                font-size: 14px;
                color: #667eea;
                font-weight: bold;
                margin-top: 5px;
            }
            .legend-container {
                margin-top: 20px;
                padding: 10px;
                background: #f8f9fa;
                border-radius: 8px;
            }
            .legend-container h4 {
                margin: 0 0 8px 0;
                font-size: 13px;
                color: #495057;
            }
            #legend-image {
                max-width: 100%;
                height: auto;
                border-radius: 4px;
            }
            .status {
                position: absolute;
                top: 10px;
                right: 10px;
                background: white;
                padding: 8px 15px;
                border-radius: 20px;
                box-shadow: 0 2px 5px rgba(0,0,0,0.2);
                z-index: 1000;
                font-size: 12px;
                color: #27ae60;
                font-weight: 600;
            }
            .loading {
                color: #f39c12;
            }
            .error {
                color: #e74c3c;
            }
        </style>
    </head>
    <body>
        <div id="container">
            <div id="sidebar">
                <h1>🌊 EMODnet Seabed Habitats</h1>
                <div class="subtitle">European Marine Observation and Data Network</div>
                
                <div id="info">
                    <strong>Interactive Map Viewer</strong><br>
                    Select a layer to visualize different seabed habitat datasets. 
                    Use your mouse to pan and zoom the map. Adjust opacity to see through to the base map.
                </div>
                
                <h3>Available Layers</h3>
                <div id="layers-list"></div>
                
                <div class="controls">
                    <div class="control-group">
                        <label for="opacity">Layer Opacity</label>
                        <input type="range" id="opacity" min="0" max="100" value="70">
                        <div class="value-display" id="opacity-value">70%</div>
                    </div>
                    
                    <div class="control-group">
                        <label for="basemap">Base Map</label>
                        <select id="basemap" style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ddd;">
                            <option value="osm">OpenStreetMap</option>
                            <option value="satellite">Satellite</option>
                            <option value="ocean">Ocean</option>
                            <option value="light">Light Gray</option>
                        </select>
                    </div>
                </div>
                
                <div class="legend-container" id="legend-container" style="display: none;">
                    <h4>Legend</h4>
                    <img id="legend-image" src="" alt="Layer legend">
                </div>
            </div>
            
            <div id="map"></div>
            <div class="status" id="status">Ready</div>
        </div>
        
        <script>
            // Initialize map
            var map = L.map('map').setView([54.0, 10.0], 4);
            
            // Base maps
            var baseMaps = {
                'osm': L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '© OpenStreetMap contributors'
                }),
                'satellite': L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
                    attribution: '© Esri'
                }),
                'ocean': L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/Ocean/World_Ocean_Base/MapServer/tile/{z}/{y}/{x}', {
                    attribution: '© Esri'
                }),
                'light': L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', {
                    attribution: '© CartoDB'
                })
            };
            
            // Add default base map
            var currentBaseMap = baseMaps['osm'];
            currentBaseMap.addTo(map);
            
            // Layer data
            const layers = {{ layers | tojson }};
            let currentLayer = layers[0].name;
            let currentOpacity = 0.7;
            let wmsLayer = null;
            
            // Function to update WMS layer
            function updateWMSLayer(layerName, opacity) {
                document.getElementById('status').textContent = 'Loading layer...';
                document.getElementById('status').className = 'status loading';
                
                // Remove existing WMS layer if present
                if (wmsLayer) {
                    map.removeLayer(wmsLayer);
                }
                
                // Add new WMS layer
                wmsLayer = L.tileLayer.wms('{{ WMS_BASE_URL }}', {
                    layers: layerName,
                    format: 'image/png',
                    transparent: true,
                    version: '1.1.0',
                    opacity: opacity,
                    attribution: 'EMODnet Seabed Habitats',
                    tiled: true
                });
                
                wmsLayer.addTo(map);
                
                // Update legend
                updateLegend(layerName);
                
                // Update status
                setTimeout(() => {
                    document.getElementById('status').textContent = 'Layer loaded';
                    document.getElementById('status').className = 'status';
                }, 500);
            }
            
            // Function to update legend
            function updateLegend(layerName) {
                const legendUrl = `{{ WMS_BASE_URL }}?service=WMS&version=1.1.0&request=GetLegendGraphic&layer=${layerName}&format=image/png`;
                const legendImg = document.getElementById('legend-image');
                const legendContainer = document.getElementById('legend-container');
                
                legendImg.src = legendUrl;
                legendImg.onload = () => {
                    legendContainer.style.display = 'block';
                };
                legendImg.onerror = () => {
                    legendContainer.style.display = 'none';
                };
            }
            
            // Create layer list
            const layersList = document.getElementById('layers-list');
            layers.forEach((layer, index) => {
                const div = document.createElement('div');
                div.className = 'layer-item';
                if (index === 0) {
                    div.className += ' active';
                }
                
                div.innerHTML = `
                    <div class="layer-title">${layer.title}</div>
                    <div class="layer-desc">${layer.description || 'EMODnet seabed habitat layer'}</div>
                `;
                
                div.onclick = () => selectLayer(layer.name, div);
                layersList.appendChild(div);
            });
            
            // Function to select layer
            function selectLayer(layerName, element) {
                // Update active state
                document.querySelectorAll('.layer-item').forEach(el => {
                    el.classList.remove('active');
                });
                element.classList.add('active');
                
                // Update map
                currentLayer = layerName;
                updateWMSLayer(currentLayer, currentOpacity);
            }
            
            // Opacity control
            const opacitySlider = document.getElementById('opacity');
            const opacityValue = document.getElementById('opacity-value');
            
            opacitySlider.oninput = function() {
                currentOpacity = this.value / 100;
                opacityValue.textContent = this.value + '%';
                if (wmsLayer) {
                    wmsLayer.setOpacity(currentOpacity);
                }
            };
            
            // Base map switcher
            document.getElementById('basemap').onchange = function(e) {
                map.removeLayer(currentBaseMap);
                currentBaseMap = baseMaps[e.target.value];
                currentBaseMap.addTo(map);
                
                // Move WMS layer to top
                if (wmsLayer) {
                    wmsLayer.bringToFront();
                }
            };
            
            // Load initial layer
            updateWMSLayer(currentLayer, currentOpacity);
            
            // Add scale control
            L.control.scale().addTo(map);
            
            // Add zoom control with custom position
            map.zoomControl.setPosition('topright');
        </script>
    </body>
    </html>
    """
    
    layers = get_available_layers()
    return render_template_string(html_template, layers=layers, WMS_BASE_URL=WMS_BASE_URL)

@app.route('/api/layers')
def api_layers():
    """API endpoint to get available layers"""
    return jsonify(get_available_layers())

@app.route('/api/capabilities')
def api_capabilities():
    """API endpoint to get WMS capabilities"""
    params = {
        'service': 'WMS',
        'version': WMS_VERSION,
        'request': 'GetCapabilities'
    }
    try:
        response = requests.get(WMS_BASE_URL, params=params, timeout=10)
        return response.content, 200, {'Content-Type': 'text/xml'}
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/legend/<path:layer_name>')
def api_legend(layer_name):
    """API endpoint to get legend for a specific layer"""
    legend_url = (
        f"{WMS_BASE_URL}?"
        f"service=WMS&version=1.1.0&request=GetLegendGraphic&"
        f"layer={layer_name}&format=image/png"
    )
    return jsonify({"legend_url": legend_url})

@app.route('/test')
def test_page():
    """Simple test page to verify WMS is working"""
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>WMS Test</title>
    </head>
    <body>
        <h1>EMODnet WMS Test</h1>
        <p>Testing direct WMS GetMap request:</p>
        <img src="https://ows.emodnet-seabedhabitats.eu/geoserver/emodnet_view/wms?service=WMS&version=1.1.0&request=GetMap&layers=all_eusm2021&bbox=-180,-90,180,90&width=768&height=384&srs=EPSG:4326&format=image/png" 
             alt="WMS Test Image" style="max-width: 100%; border: 1px solid black;">
        <p>If you see a map image above, the WMS service is working correctly.</p>
    </body>
    </html>
    """
    return html

if __name__ == '__main__':
    print("\n" + "="*60)
    print("🌊 EMODnet Seabed Habitats Viewer")
    print("="*60)
    print("\nStarting Flask server...")
    print("Open http://localhost:5000 in your browser")
    print("\nAvailable endpoints:")
    print("  /              - Main interactive map viewer")
    print("  /test          - Test WMS connectivity")
    print("  /api/layers    - Get list of available layers (JSON)")
    print("  /api/capabilities - Get WMS capabilities (XML)")
    print("  /api/legend/<layer> - Get legend URL for a layer")
    print("\nPress Ctrl+C to stop the server")
    print("-"*60 + "\n")
    
    app.run(debug=True, port=5000)