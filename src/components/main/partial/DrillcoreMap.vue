<template>
    <div id="map" class="map">
    </div>
</template>

<script>
  import LayerSwitcher from 'ol-layerswitcher/dist/ol-layerswitcher'

  import Map from 'ol/map';
  import SourceVector from 'ol/source/vector';
  import LayerVector from 'ol/layer/vector';
  import Select from 'ol/interaction/select';
  import SourceXYZ from 'ol/source/xyz';
  import Feature from 'ol/feature';
  import GeomPoint from 'ol/geom/point';
  import Style from 'ol/style/style';
  import Circle from 'ol/style/circle';
  import Fill from 'ol/style/fill';
  import Stroke from 'ol/style/stroke';
  import Text from 'ol/style/text';
  import Condition from 'ol/events/condition';
  import DragBoxInteraction from 'ol/interaction/dragbox';
  import View from 'ol/view';
  import Proj from 'ol/proj';
  import LayerGroup from 'ol/layer/group';
  import LayerTile from 'ol/layer/tile';
  import SourceOSM from 'ol/source/osm';
  import SourceStamen from 'ol/source/stamen';
  import TileWMS from "ol/source/tilewms";
  import 'ol/ol.css';
  import 'ol-layerswitcher/src/ol-layerswitcher.css';

  export default {
    props: ['results', 'currentResults', 'value'],
    name: "drillcore-map",
    data() {
      return {
        map: undefined,
        vectorSource: new SourceVector({}),
        allVectors: new SourceVector({}),
      }
    },
    mounted: function () {

      const vectorLayer = new LayerVector({
        source: this.vectorSource,
        zIndex: 100
      });

      const allVectorsLayer = new LayerVector({
        source: this.allVectors,
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
          new LayerTile({
            /* extent: [-13884991, 2870341, -7455066, 6338219],*/
            title: 'Bedrock age <br /><img src="https://gis.geocollections.info/geoserver/wms?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&WIDTH=20&HEIGHT=20&LAYER=IGME5000:EuroGeology&legend_options=fontName:DejaVu%20Sans%20ExtraLight;fontAntiAliasing:true;fontColor:0x333333;fontSize:10;bgColor:0xFFFFff;dpi:96" /> ',
            visible: false,
            source: new TileWMS({
              url: 'https://gis.geocollections.info/geoserver/wms',
              params: { 'LAYERS': 'IGME5000:EuroGeology', 'TILED': true },
              serverType: 'geoserver',
              // Countries have transparency, so do not fade tiles:
              // transition: 0,
              projection: ''
            }),
            opacity: 0.5,
          })
        ]
      });

      this.map = new Map({
        target: 'map',
        layers: [basemaps, overlays, allVectorsLayer],
        view: new View({
          center: Proj.fromLonLat([25, 64]),
          zoom: 4
        })
      });

      this.map.addLayer(vectorLayer);
      this.map.addControl(new LayerSwitcher());
      this.addAllPoints(this.results);
      // this.addPoints(this.results);
      this.addPointerMoveInteraction();
      this.addSelectInteraction()

      console.log('drillcoreMap.vue')
      console.log(this.results)
      console.log(this.currentResults)
      console.log(this.idsFromMap)
      console.log('drillcoreMap.vue')

    },
    methods: {

      addPointerMoveInteraction() {
        let selectPointerMove = new Select({
          condition: Condition.pointerMove
        });
        this.map.addInteraction(selectPointerMove);

        selectPointerMove.on('select', function (e) {
          if (e.selected.length != 0) {
            e.selected[0].getStyle().getText().setScale(1.4);
          }
          if (e.deselected.length != 0) {
            e.deselected[0].getStyle().getText().setScale(0)
          }
        });
      },


      addSelectInteraction() {
        let select = new Select({
          multi: true,
        });
        this.select = select;
        let selectedFeatures = this.select.getFeatures();

        this.map.addInteraction(this.select);

        this.select.on("select", function () {
          let drillcoreIds = [];

          selectedFeatures.getArray().map(function (feature) {
            drillcoreIds.push(feature.getId().toString());
          })
          // siteSearchComponent.searchDrillcoreId = siteIds.toString();
          // siteSearchComponent.searchSites();
          // TODO: Send ids to drillcore component
          console.log(drillcoreIds);
        })

        let dragBox = new DragBoxInteraction({
          //condition: ol.events.condition.platformModifierKeyOnly
        });
        this.map.addInteraction(dragBox);

        let allDrillcores = this.allVectors;

        dragBox.on('boxend', function () {
          let drillcoreIds = [];

          // features that intersect the box are added to the collection of
          // selected features
          selectedFeatures.clear();
          let extent = dragBox.getGeometry().getExtent();
          allDrillcores.forEachFeatureIntersectingExtent(extent, function (feature) {
            selectedFeatures.push(feature);
            drillcoreIds.push(feature.getId().toString());
          });
          // siteSearchComponent.searchDrillcoreId = siteIds.toString();
          // siteSearchComponent.searchSites();
          // TODO: Send ids to drillcore component
          console.log(drillcoreIds);
        });
      },

      clearFeatures() {
        if (this.select.getFeatures())
          this.select.getFeatures().clear();
      },

      addAllPoints(results) {
        console.log(results);
        for (const entity in results) {
          if (results[entity].longitude !== undefined) {
            let point = new Feature({
              name: results[entity].name,
              id: results[entity].id,
              geometry: new GeomPoint(Proj.fromLonLat([results[entity].longitude, results[entity].latitude]))
            });
            point.setId(results[entity].id);
            point.setStyle(new Style({
              image: new Circle({
                radius: 7,
                fill: new Fill({ color: '#6BB745' }),
                stroke: new Stroke({
                  color: 'black',
                  width: 1
                })
              }),
              zIndex: 100,
              text: new Text({
                scale: 0,
                text: results[entity].name,
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
            this.allVectors.addFeature(point);
          }
        }
      },

      addPoints(sites) {
        for (let k = 0; k < this.allVectors.getFeatures().length; k++) {
          this.allVectors.getFeatures()[k].setStyle(new Style({
            image: new Circle({
              radius: 7,
              fill: new Fill({ color: '#6BB745' }),
              stroke: new Stroke({
                color: 'black',
                width: 1
              }),
            }),
            //zIndex : 150,
            text: new Text({
              scale: 0,
              text: this.allVectors.getFeatures()[k].get('name'),
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
        }

        if (sites && Object.keys(sites).length < this.allVectors.getFeatures().length) {
          for (let i = 0; i < Object.keys(sites).length; i++) {
            this.allVectors.getFeatureById(sites[i].id).setStyle(new Style({
              image: new Circle({
                radius: 7,
                fill: new Fill({ color: '#CD154F' }),
                stroke: new Stroke({
                  color: 'black',
                  width: 1
                }),
              }),
              zIndex: 100,
              text: new Text({
                scale: 0,
                text: this.allVectors.getFeatureById(sites[i].id).get('name'),
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
          }
        }
      }
    }
  }
</script>

<style scoped>
  .map {
    height: 400px;
    min-width: 300px;
    width: 100%;
  }
</style>
