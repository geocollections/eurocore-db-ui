<template>
  <div id="map" class="map">
  </div>
</template>

<script>
  import LayerSwitcher from 'ol-layerswitcher/dist/ol-layerswitcher'

  import Map from 'ol/map';
  import SourceVector from 'ol/source/vector';
  import LayerVector from 'ol/layer/vector';
  import SourceXYZ from 'ol/source/xyz';
  import Feature from 'ol/feature';
  import GeomPoint from 'ol/geom/point';
  import Style from 'ol/style/style';
  import Circle from 'ol/style/circle';
  import Fill from 'ol/style/fill';
  import Stroke from 'ol/style/stroke';
  import Text from 'ol/style/text';
  import View from 'ol/view';
  import Proj from 'ol/proj';
  import LayerGroup from 'ol/layer/group';
  import LayerTile from 'ol/layer/tile';
  import SourceOSM from 'ol/source/osm';
  import SourceStamen from 'ol/source/stamen';
  import TileWMS from 'ol/source/tilewms';
  import ScaleLine from 'ol/control/scaleline';
  import Attribution from 'ol/control/attribution';
  import 'ol/ol.css'
  import 'ol-layerswitcher/src/ol-layerswitcher.css'

  export default {
    props: ['lat', 'lon', 'name'],
    name: "detail-map",
    data() {
      return {
        map: undefined,
        vectorSource: new SourceVector({})
      }
    },
    mounted: function () {

      const vectorLayer = new LayerVector({
        source: this.vectorSource,
        zIndex: 100
      });

      const basemaps = new LayerGroup({
        title: 'Base maps',
        layers: [
          new LayerTile({
            title: 'Stamen dark',
            type: 'base',
            visible: false,
            source: new SourceStamen({
              layer: 'toner'
            })
          }),
          new LayerTile({
            title: 'Stamen terrain',
            type: 'base',
            group: 'group-name',
            visible: false,
            source: new SourceStamen({
              layer: 'terrain'
            })
          }),
          new LayerTile({
            title: 'OpenStreetMap',
            type: 'base',
            visible: false,
            source: new SourceOSM()
          }),
          new LayerTile({
            title: 'ArcGIS',
            type: 'base',
            visible: true,
            source: new SourceXYZ({
              url: 'https://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}'
            })
          })
        ]
      });

      const overlays = new LayerGroup({
        title: 'Overlays',
        layers: [
          // Bedrock age map for Europe and little bit more
          new LayerTile({
            title: 'Bedrock age <br /><img src="https://gis.geocollections.info/geoserver/wms?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&WIDTH=20&HEIGHT=20&LAYER=IGME5000:EuroGeology&legend_options=fontName:DejaVu%20Sans%20ExtraLight;fontAntiAliasing:true;fontColor:0x333333;fontSize:10;bgColor:0xFFFFff;dpi:96" /> ',
            visible: true,
            source: new TileWMS({
              url: 'https://gis.geocollections.info/geoserver/wms',
              params: { 'LAYERS': 'IGME5000:EuroGeology', 'TILED': true },
              serverType: 'geoserver',
              projection: '',
              attributions: 'Bedrock age: <a target="_blank" href="https://www.bgr.bund.de/EN/Themen/Sammlungen-Grundlagen/GG_geol_Info/Karten/International/Europa/IGME5000/IGME_Project/IGME_Projectinfo.html?nn=1556388">IGME 5000</a>. '
            }),
            opacity: 0.5,
          }),
          // Rocks of Finland
          new LayerTile({
            title: 'Rocks of Finland <br /><img src="https://gtkdata.gtk.fi/onegeology/wms/1ge/legend_bedrock_lithology.png?">',
            visible: false,
            source: new TileWMS({
              url: 'https://gtkdata.gtk.fi/arcgis/services/Inspire/GTK_Bedrock_and_Superficial_Geology/MapServer/WMSServer?',
              params: { 'LAYERS': 'FI_GTK_1M_Bedrock_Lithology', 'TILED': true },
              projection: '',
              attributions: 'Rocks of Finland: <a target="_blank" href="https://en.gtk.fi/">Geological Survey of Finland</a>. '
            }),
            opacity: 0.5,
          }),
        ]
      });

      this.map = new Map({
        target: 'map',
        layers: [basemaps, overlays],
        view: new View({
          center: Proj.fromLonLat([29.34424401655, 62.856645860855]),
          zoom: 4
        })
      });

      this.map.addLayer(vectorLayer);
      this.map.addControl(new LayerSwitcher());
      this.map.addControl(new ScaleLine());
      this.addPointWithName(this.name, this.lon, this.lat);
    },
    methods: {
      addPointWithName(name, longitude, latitude) {
        this.vectorSource.clear();
        if (longitude !== undefined) {
          let pointWithName = new Feature({
            geometry: new GeomPoint(Proj.fromLonLat([longitude, latitude]))
          });
          pointWithName.setStyle(new Style({
            image: new Circle({
              radius: 7,
              fill: new Fill({ color: '#CD154F' }),
              stroke: new Stroke({
                color: 'black',
                width: 1
              })
            }),
            text: new Text({
              scale: 1.4,
              text: name,
              offsetY: -25,
              fill: new Fill({
                color: 'black'
              }),
              stroke: new Stroke({
                color: 'white',
                width: 3.5
              })
            })
          }));

          this.vectorSource.addFeature(pointWithName);
          this.map.getView().setZoom(5);
          this.map.getView().setCenter(Proj.fromLonLat([longitude, latitude]));
        }
      }
    }
  }
</script>

<style scoped>
  .map {
    height: 400px;
  }
</style>
