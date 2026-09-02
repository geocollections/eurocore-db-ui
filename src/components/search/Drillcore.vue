<template>
  <div id="search-component">

    <spinner v-show="isSearching" class="loading-overlay" size="huge" message="Searching..."></spinner>

    <div class="row">
      <div class="col">
        <h2>Drillcore search</h2>
      </div>
    </div>


    <div class="row align-items-center">
      <div class="col-md-12 col-lg-6">

        <div class="form-group">
          <vue-multiselect
            v-model="searchParameters.drillcoreName.name"
            :options="drillcoreNames"
            placeholder="Drillcore Name"
            label="name"
            track-by="name" />
        </div>

        <div class="form-group">
          <vue-multiselect
            v-model="searchParameters.depositName.name"
            :options="depositNames"
            placeholder="Deposit Name"
            label="deposit__name"
            track-by="deposit__name" />
        </div>

        <div class="form-group">
          <vue-multiselect
            v-model="searchParameters.oreType.name"
            :options="oreTypes"
            placeholder="Ore type"
            label="deposit__genetic_type__name"
            track-by="deposit__genetic_type__name" />
        </div>

        <div class="form-group">
          <vue-multiselect
            v-model="searchParameters.commodity.name"
            :options="commodities"
            placeholder="Main commodity"
            label="deposit__main_commodity"
            track-by="deposit__main_commodity" />
        </div>

        <div class="form-group">
          <vue-multiselect
            v-model="searchParameters.coreDepositor.name"
            :options="coreDepositors"
            placeholder="Core depositor"
            track-by="core_depositor__acronym"
            :custom-label="customLabelForCoreDepositors" />
        </div>

        <div class="searchButtons row">
          <span class="mr-2 mb-2">
            <button class="btn btn-primary" title="Sends request with inserted data" @click="searchEntities(searchParameters)">SEARCH DRILLCORES</button>
          </span>

          <span class="mr-2 mb-2">
            <button class="btn btn-danger" title="Clears search fields" @click="resetSearchParameters()">RESET FORM</button>
          </span>
        </div>
      </div>


      <div class="col-md-12 col-lg-6">
        <div id="map" class="map"></div>
      </div>
    </div>


    <div class="row mt-3">
      <div class="col">
        <p v-if="isSearching">Loading data...</p>
        <p v-else-if="!isSearching && noResults">No results found. Please try again.</p>
        <p v-else>Found <b>{{response.count}}</b> result(s). </p>
      </div>
    </div>


    <div class="row" v-if="response.count > 0">
      <div class="col-sm-6 col-md-3 pl-3 pr-3 t-paginate-by-center">
        <b-form-select v-model="searchParameters.paginateBy" :options="paginationOptions" class="mb-3"></b-form-select>
      </div>

      <div class="col-sm-12 col-md-3 mb-3 export-center">
        <export-buttons filename="drillcoreSearch"/>
      </div>

      <div class="col-sm-12 col-md-6 pagination-center">
        <b-pagination
          size="md" align="right" :limit="5" :total-rows="response.count" v-model="searchParameters.page" :per-page="searchParameters.paginateBy">
        </b-pagination>
      </div>
    </div>


    <div v-show="response.count > 0" class="row">
      <div class="col">
          <div class="table-responsive">
            <table ref="table" id="table-search" class="table table-hover table-bordered ">
              <thead class="thead-light">
                <tr class="th-sort">
                  <th>
                    <span @click="changeOrder('id')">
                      <font-awesome-icon v-if="searchParameters.orderBy !== 'id' && searchParameters.orderBy !== '-id'" :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection" />
                      ID
                    </span>
                  </th>

                  <th>
                    <span @click="changeOrder('name')">
                      <font-awesome-icon v-if="searchParameters.orderBy !== 'name' && searchParameters.orderBy !== '-name'" :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection" />
                      Name
                    </span>
                  </th>

                  <th>
                    <span @click="changeOrder('deposit__name')">
                      <font-awesome-icon v-if="searchParameters.orderBy !== 'deposit__name' && searchParameters.orderBy !== '-deposit__name'" :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection" />
                      Deposit
                    </span>
                  </th>

                  <th>
                    <span @click="changeOrder('deposit__main_commodity')">
                      <font-awesome-icon v-if="searchParameters.orderBy !== 'deposit__main_commodity' && searchParameters.orderBy !== '-deposit__main_commodity'" :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection" />
                      Commodity
                    </span>
                  </th>

                  <th>
                    <span @click="changeOrder('latitude')">
                      <font-awesome-icon v-if="searchParameters.orderBy !== 'latitude' && searchParameters.orderBy !== '-latitude'" :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection" />
                      Latitude
                    </span>
                  </th>

                  <th>
                    <span @click="changeOrder('longitude')">
                      <font-awesome-icon v-if="searchParameters.orderBy !== 'longitude' && searchParameters.orderBy !== '-longitude'" :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection" />
                      Longitude
                    </span>
                  </th>

                  <th>
                    <span @click="changeOrder('hole_length')">
                      <font-awesome-icon v-if="searchParameters.orderBy !== 'hole_length' && searchParameters.orderBy !== '-hole_length'" :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection" />
                      Length
                    </span>
                  </th>

                  <th>
                    <span @click="changeOrder('hole_dip')">
                      <font-awesome-icon v-if="searchParameters.orderBy !== 'hole_dip' && searchParameters.orderBy !== '-hole_dip'" :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection" />
                      Dip
                    </span>
                  </th>

                  <th>
                    <span @click="changeOrder('hole_azimuth')">
                      <font-awesome-icon v-if="searchParameters.orderBy !== 'hole_azimuth' && searchParameters.orderBy !== '-hole_azimuth'" :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection" />
                      Azimuth
                    </span>
                  </th>

                  <th></th>
                </tr>
              </thead>

              <tbody>
                <tr v-for="drillcore in response.results">
                  <td>{{drillcore.id}}</td>
                  <td>
                    <router-link :to="{ path: '/drillcore/' + drillcore.id }">{{drillcore.name}}</router-link>
                  </td>
                  <td>
                    <router-link :to="{ path: '/deposit/' + drillcore.deposit__id }">{{drillcore.deposit__name}}</router-link>
                  </td>
                  <td>{{drillcore.deposit__main_commodity}}</td>
                  <td v-if="drillcore.latitude">{{drillcore.latitude.toFixed(5)}}</td>
                  <td v-if="drillcore.longitude">{{drillcore.longitude.toFixed(5)}}</td>
                  <td>{{drillcore.hole_length}}</td>
                  <td>{{drillcore.hole_dip}}</td>
                  <td>{{drillcore.hole_azimuth}}</td>
                  <td class="tableexport-ignore">
                    <router-link :to="{ path: '/drillcore_data/' + drillcore.id }">Show data</router-link>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
    </div>

    <div class="row mt-3" v-if="response.count > 0">
      <div class="col-xs-1 pl-3 pr-3 mb-3 b-paginate-by-center">
        <b-form-select v-model="searchParameters.paginateBy" :options="paginationOptions"></b-form-select>
      </div>

      <div class="col mb-3 pagination-center">
        <b-pagination
          size="md" align="right" :limit="5" :total-rows="response.count" v-model="searchParameters.page" :per-page="searchParameters.paginateBy">
        </b-pagination>
      </div>
    </div>

  </div>
</template>

<script>
  import VueMultiselect from "vue-multiselect/src/Multiselect";
  import ExportButtons from './detail/partial/ExportButtons'
  import FontAwesomeIcon from '@fortawesome/vue-fontawesome'
  import faSort from '@fortawesome/fontawesome-free-solid/faSort'
  import faSortUp from '@fortawesome/fontawesome-free-solid/faSortUp'
  import faSortDown from '@fortawesome/fontawesome-free-solid/faSortDown'
  import Spinner from 'vue-simple-spinner'
  // import DrillcoreMap from "../main/partial/DrillcoreMap";

  /* MAP IMPORTS START */
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
  import ScaleLine from 'ol/control/scaleline';
  import 'ol/ol.css'
  import 'ol-layerswitcher/src/ol-layerswitcher.css'
  /* MAP IMPORTS END */

  export default {
    components: {
      // DrillcoreMap,
      VueMultiselect,
      ExportButtons,
      FontAwesomeIcon,
      Spinner
    },

    name: "drillcore",

    data() {
      return {
        API_URL: 'https://api.eurocore.rocks/',
        isAuthenticated: false,
        isSearching: false,
        noResults: null,
        searchParameters: {
          drillcoreName: { name: '', field: 'name' },
          depositName: { name: '', field: 'deposit__name' },
          oreType: { name: '', field: 'deposit__genetic_type__name', },
          commodity: { name: '', field: 'deposit__main_commodity' },
          coreDepositor: { name: '', field: 'core_depositor__acronym' },
          fastSearch: '',
          page: 1,
          paginateBy: 25,
          orderBy: 'id'
        },
        response: {
          count: 0,
          results: []
        },
        responseForMap: [],
        drillcoreIdsFromMap: null,
        map: undefined,
        vectorSource: new SourceVector(),
        allVectors: new SourceVector(),
        mapResponse: {
          count: 0,
          results: []
        },
        drillcoreNames: [],
        depositNames: [],
        oreTypes: [],
        commodities: [],
        coreDepositors: [],
        paginationOptions: [
          { value: 10, text: 'Show 10 results per page' },
          { value: 25, text: 'Show 25 results per page' },
          { value: 50, text: 'Show 50 results per page' },
          { value: 100, text: 'Show 100 results per page' },
          { value: 250, text: 'Show 250 results per page' },
          { value: 500, text: 'Show 500 results per page' },
          { value: 1000, text: 'Show 1000 results per page' }
        ],
      }
    },

    metaInfo: {
      title: 'EUROCORE Data Portal: Drillcores'
    },

    computed: {
      icon() {
        return faSort;
      },

      sortingDirection() {
        return this.searchParameters.orderBy.includes('-') ? faSortDown : faSortUp
      }
    },

    watch: {
      // TODO: Got to test it performance wise, maybe dependent search isnt necessary here
      'searchParameters': {
        handler: function () {
          console.log(this.searchParameters)
          this.isSearching = true
          this.searchEntitiesAndPopulate(this.searchParameters, this.drillcoreIdsFromMap)
        },
        deep: true
      },
      'searchParameters.drillcoreName.name': function (newVal, oldVal) {
        this.resetPointColor(this.allVectors);
        this.drillcoreIdsFromMap = null;
        this.searchParameters.fastSearch = '';
      },
      'searchParameters.depositName.name': function () {
        this.resetPointColor(this.allVectors);
        this.drillcoreIdsFromMap = null;
        this.searchParameters.fastSearch = '';
      },
      'searchParameters.oreType.name': function () {
        this.resetPointColor(this.allVectors);
        this.drillcoreIdsFromMap = null;
        this.searchParameters.fastSearch = '';
      },
      'searchParameters.commodity.name': function () {
        this.resetPointColor(this.allVectors);
        this.drillcoreIdsFromMap = null;
        this.searchParameters.fastSearch = '';
      },
      'searchParameters.coreDepositor.name': function () {
        this.resetPointColor(this.allVectors);
        this.drillcoreIdsFromMap = null;
        this.searchParameters.fastSearch = '';
      },
      'searchParameters.paginateBy': function(newVal, oldVal) {
        this.toastInfo('Showing <strong>' + newVal + '</strong> results per page!')
      },
      'drillcoreIdsFromMap': function (newVal, oldVal) {
        if (newVal != null) {
          if (newVal.length > 0) {
            this.addParamsToUrl(this.searchParameters, this.drillcoreIdsFromMap);
            this.searchEntitiesUsingMap(this.drillcoreIdsFromMap);
            this.searchParameters.fastSearch = '';
          }
        }
      },
      'mapResponse.results': function () {
        this.addAllPoints(this.mapResponse.results);
        this.colorMapPointsUsingIds(this.drillcoreIdsFromMap, this.allVectors)
      },
      'responseForMap': function (newVal, oldVal) {
        if (typeof (newVal) !== 'undefined') {
          if (this.responseForMap.length !== this.allVectors.getFeatures().length) {
            this.resetPointColor(this.allVectors)
            this.updatePointColor(this.responseForMap, this.allVectors)
          }
        }
      },
    },

    beforeRouteUpdate (to, from, next) {
      if (Object.keys(to.query).length > 0 && to.query.constructor === Object) {
        if (to.query.fastSearch) {
          this.searchParameters.fastSearch = to.query.fastSearch
          // this.fastSearch(to.query.fastSearch)
        }
        //  TODO: Params from url to searchParams
      }
      next()
    },

    created: function () {
      if (Object.keys(this.$route.query).length > 0 && this.$route.query.constructor === Object) {
        console.log(this.$route.query)
        if (this.$route.query.fastSearch) {
          this.searchParameters.fastSearch = this.$route.query.fastSearch
        } else {
          this.getParamsFromUrl(this.$route.query);
        }
      } else if(this.$session.exists() && this.$session.get('drillcoreIdsFromMap') != null) {
        this.editDataUsingDrillcoreIds();
      } else if (this.$session.exists() && this.$session.get('drillcore') != null) {
        this.searchParameters = this.$session.get('drillcore');
      } else {
        this.searchEntitiesAndPopulate(this.searchParameters);
      }

      this.getMapData();
    },

    mounted: function () {
      this.initMap();
    },

    updated: function () {
      this.reflowFloatThead();
      this.addFloatingTableHeaders(); // Won't work if its not in updated
    },

    beforeDestroy: function () {
      this.addSessionStorage();
    },

    methods: {

      searchEntitiesAndPopulate(params, drillcoreIds) {
        if (params.fastSearch !== '') {
          this.fastSearch(params.fastSearch);
          this.fastSearchForMap(params.fastSearch);
          this.populateDrillcoreNames(params);
          this.populateDepositNames(params);
          this.populateOreTypes(params);
          this.populateCommodities(params);
          this.populateCoreDepositors(params);
        } else if (drillcoreIds != null && params.drillcoreName.name === '' && params.depositName.name === '' && params.oreType.name === '' && params.commodity.name === '' && params.coreDepositor.name === '') {
          this.addParamsToUrl(params, drillcoreIds);

          this.searchEntitiesUsingMap(drillcoreIds);
          this.populateDrillcoreNames(params);
          this.populateDepositNames(params);
          this.populateOreTypes(params);
          this.populateCommodities(params);
          this.populateCoreDepositors(params);
        } else {
          this.addParamsToUrl(params, drillcoreIds);

          this.searchEntities(params);
          this.searchEntitiesForMap(params);
          this.populateDrillcoreNames(params);
          this.populateDepositNames(params);
          this.populateOreTypes(params);
          this.populateCommodities(params);
          this.populateCoreDepositors(params);
        }
      },

      searchEntitiesUsingMap(drillcoreIds) {
        drillcoreIds += '';
        let ids = 'id=';
        if (drillcoreIds.includes(',')) {
          ids = 'id__in=';
        }
        this.$http.get(this.API_URL + 'drillcore/?' + ids + drillcoreIds, {params: {format: 'json', page: this.searchParameters.page, paginate_by: this.searchParameters.paginateBy, order_by: this.searchParameters.orderBy}}).then(response => {
          console.log(response);
          this.isSearching = false
          if (response.status === 200) {
            this.noResults = response.body.count === 0
            this.response.count = response.body.count;
            this.response.results = response.body.results;
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
          this.isSearching = false
        })
      },

      searchEntities(searchParameters) {
        let url = this.buildSearchUrl(searchParameters);

        this.$http.get(url, {params: {format: 'json', page: searchParameters.page, paginate_by: searchParameters.paginateBy, order_by: searchParameters.orderBy}}).then(response => {
          console.log(response);
          this.isSearching = false
          if (response.status === 200) {
            this.noResults = response.body.count === 0
            this.response.count = response.body.count;
            this.response.results = response.body.results;
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
          this.isSearching = false
        })

      },

      //TEST ONLY
      searchEntitiesForMap(searchParameters) {
        let url = this.buildSearchUrl(searchParameters);

        this.$http.get(url, {params: {format: 'json', paginate_by: 100}}).then(response => {
          console.log(response);
          this.isSearching = false
          if (response.status === 200) {
            this.responseForMap = response.body.results;
          }
        })

      },

      fastSearch(drillcoreName) {
        this.$http.get(this.API_URL + 'drillcore/', {params: {format: 'json', name__icontains: drillcoreName, page: this.searchParameters.page, paginate_by: this.searchParameters.paginateBy, order_by: this.searchParameters.orderBy}}).then(response => {
          console.log(response);
          this.isSearching = false
          if (response.status === 200) {
            this.noResults = response.body.count === 0
            this.response.count = response.body.count;
            this.response.results = response.body.results;
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
          this.isSearching = false
        })
      },

      //TEST ONLY
      fastSearchForMap(drillcoreName) {
        this.$http.get(this.API_URL + 'drillcore/', {params: {format: 'json', name__icontains: drillcoreName, paginate_by: 100}}).then(response => {
          console.log(response);
          this.isSearching = false
          if (response.status === 200) {
            this.responseForMap = response.body.results;
          }
        })
      },

      buildSearchUrl(params) {
        let url = this.API_URL + 'drillcore/?';

        Object.keys(params).forEach(function (key) {
          // console.log(key + ' ' + params[key]);

          if (typeof(params[key]) === 'object') {

            if (params[key].name !== '' && params[key].name != null) {
              // console.log(params[key].field + '=' + params[key].name[params[key].field]); deposit__name=Kevitsa
              url += params[key].field + '=' + params[key].name[params[key].field] + '&'
            }
          }

        });

        if (url.slice(-1) === '?' || url.slice(-1) === '&') {
          url = url.slice(0, -1);
        }
        return url;
      },

      addParamsToUrl(params, drillcoreIds) {
        console.log('IDS: ')
        console.log(drillcoreIds)
        console.log('PARAMS: ')
        console.log(params)
        if (drillcoreIds !== null && typeof (drillcoreIds) !== 'undefined') {
          const drillcoreIdsString = drillcoreIds + '';
          const orderBy = params.orderBy;
          const page = params.page;
          const paginateBy = params.paginateBy;
          this.$router.replace(
            {
              name: 'Drillcore',
              query:
                {
                  drillcoreIds: drillcoreIdsString,
                  orderBy: orderBy,
                  page: page,
                  paginateBy: paginateBy
                }
            });
        } else if (params !== null) {
          let drillcoreName = '';
          let depositName = '';
          let oreType = '';
          let commodity = '';
          let coreDepositor = '';
          if (params.drillcoreName.name !== '' && params.drillcoreName.name !== null) {
            drillcoreName = params.drillcoreName.name.name;
          }
          if (params.depositName.name !== '' && params.depositName.name !== null) {
            depositName = params.depositName.name.deposit__name;
          }
          if (params.oreType.name !== '' && params.oreType.name !== null) {
            oreType = params.oreType.name.deposit__genetic_type__name;
          }
          if (params.commodity.name !== '' && params.commodity.name !== null) {
            commodity = params.commodity.name.deposit__main_commodity;
          }
          if (params.coreDepositor.name !== '' && params.coreDepositor.name !== null) {
            coreDepositor = params.coreDepositor.name.core_depositor__acronym;
          }
          const orderBy = params.orderBy;
          const page = params.page;
          const paginateBy = params.paginateBy;

          this.$router.replace(
            {
              name: 'Drillcore',
              query:
                {
                  drillcoreName: drillcoreName,
                  depositName: depositName,
                  oreType: oreType,
                  commodity: commodity,
                  coreDepositor: coreDepositor,
                  orderBy: orderBy,
                  page: page,
                  paginateBy: paginateBy
                }
            });
        }
      },

      getParamsFromUrl(params) {
        if (params.drillcoreIds !== null && typeof (params.drillcoreIds) !== 'undefined') {
          const drillcoreIds = params.drillcoreIds.split(',');
          const orderBy = params.orderBy;
          const page = parseInt(params.page);
          const paginateBy = parseInt(params.paginateBy);

          this.drillcoreIdsFromMap = drillcoreIds;

          this.searchParameters = {
            drillcoreName: { name: '', field: 'name' },
            depositName: { name: '', field: 'deposit__name' },
            oreType: { name: '', field: 'deposit__genetic_type__name', },
            commodity: { name: '', field: 'deposit__main_commodity' },
            coreDepositor: { name: '', field: 'core_depositor__acronym' },
            fastSearch: '',
            page: page,
            paginateBy: paginateBy,
            orderBy: orderBy
          };

        } else {
          let drillcoreName = '';
          let depositName = '';
          let oreType = '';
          let commodity = '';
          let coreDepositor = '';

          if (params.drillcoreName !== '' && params.drillcoreName !== null) {
            drillcoreName = { name: params.drillcoreName };
          }
          if (params.depositName !== '' && params.depositName !== null) {
            depositName = { deposit__name: params.depositName };
          }
          if (params.oreType !== '' && params.oreType !== null) {
            oreType = { deposit__genetic_type__name: params.oreType };
          }
          if (params.commodity !== '' && params.commodity !== null) {
            commodity = { deposit__main_commodity: params.commodity };
          }
          if (params.coreDepositor !== '' && params.coreDepositor !== null) {
            coreDepositor = { core_depositor__acronym: params.coreDepositor };
          }
          const orderBy = params.orderBy;
          const page = parseInt(params.page);
          const paginateBy = parseInt(params.paginateBy);

          this.searchParameters = {
            drillcoreName: { name: drillcoreName, field: 'name' },
            depositName: { name: depositName, field: 'deposit__name' },
            oreType: { name: oreType, field: 'deposit__genetic_type__name', },
            commodity: { name: commodity, field: 'deposit__main_commodity' },
            coreDepositor: { name: coreDepositor, field: 'core_depositor__acronym' },
            fastSearch: '',
            page: page,
            paginateBy: paginateBy,
            orderBy: orderBy
          };
        }
      },

      editDataUsingDrillcoreIds() {
        let page = 1;
        let paginateBy = 25;
        let orderBy = 'id';

        if (this.$session.get('drillcorePage') != null) {
          page = this.$session.get('drillcorePage');
        }
        if (this.$session.get('drillcorePaginateBy') != null) {
          paginateBy = this.$session.get('drillcorePaginateBy');
        }
        if (this.$session.get('drillcoreOrderBy') != null) {
          orderBy = this.$session.get('drillcoreOrderBy');
        }

        this.drillcoreIdsFromMap = this.$session.get('drillcoreIdsFromMap');
        this.searchParameters = {
          drillcoreName: { name: '', field: 'name' },
          depositName: { name: '', field: 'deposit__name' },
          oreType: { name: '', field: 'deposit__genetic_type__name', },
          commodity: { name: '', field: 'deposit__main_commodity' },
          coreDepositor: { name: '', field: 'core_depositor__acronym' },
          fastSearch: '',
          page: page,
          paginateBy: paginateBy,
          orderBy: orderBy
        };
      },



      /***************************************
       ***** MULTISELECT POPULATE START ******
       ***************************************/

      populateDrillcoreNames(params) {

        let url = this.buildSearchUrl(params);
        console.log(url);
        this.$http.get(url, {params: {distinct: 'true', format: 'json', fields: 'name'}}).then(response => {
          console.log(response);
          if (response.status === 200) {
            if (response.body.count > 0) {
              this.drillcoreNames = response.body.results;
            }
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      populateDepositNames(params) {
        let url = this.buildSearchUrl(params);

        this.$http.get(url, {params: {deposit__name__isnull: 'false', distinct: 'true', format: 'json', fields: 'deposit__name'}}).then(response => {
          console.log(response);
          if (response.status === 200) {
            if (response.body.count > 0) {
              this.depositNames = response.body.results;
            }
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      populateOreTypes(params) {
        let url = this.buildSearchUrl(params);

        this.$http.get(url, {params: {deposit__genetic_type__name__isnull: 'false', distinct: 'true', format: 'json', fields: 'deposit__genetic_type__name'}}).then(response => {
          console.log(response);
          if (response.status === 200) {
            if (response.body.count > 0) {
              this.oreTypes = response.body.results;
            }
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      populateCommodities(params) {
        let url = this.buildSearchUrl(params);

        this.$http.get(url, {params: {deposit__main_commodity__isnull: 'false', distinct: 'true', format: 'json', fields: 'deposit__main_commodity'}}).then(response => {
          console.log(response);
          if (response.status === 200) {
            if (response.body.count > 0) {
              this.commodities = response.body.results;
            }
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      populateCoreDepositors(params) {
        let url = this.buildSearchUrl(params);

        this.$http.get(url, {params: {distinct: 'true', format: 'json', fields: 'core_depositor__name,core_depositor__acronym'}}).then(response => {
          console.log(response);
          if (response.status === 200) {
            if (response.body.count > 0) {
              this.coreDepositors = response.body.results;
            }
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      /***************************************
       *****  MULTISELECT POPULATE END  ******
       ***************************************/



      customLabelForCoreDepositors(option) {
        return typeof (option.core_depositor__name) !== 'undefined' ? `${option.core_depositor__acronym} - ${option.core_depositor__name}` : `${option.core_depositor__acronym}`
      },

      changeOrder(orderValue) {
        if (this.searchParameters.orderBy === orderValue) {
          if (orderValue.charAt(0) !== '-') {
            orderValue = '-' + orderValue;
          } else {
            orderValue = orderValue.substring(1);
          }
        }
        this.searchParameters.page = 1;
        this.searchParameters.orderBy = orderValue;
      },

      resetSearchParameters() {
        console.log("BEFORE");
        this.resetPointColor(this.allVectors);
        console.log(this.searchParameters);
        this.searchParameters =
          {
            drillcoreName: { name: '', field: 'name' },
            depositName: { name: '', field: 'deposit__name' },
            oreType: { name: '', field: 'deposit__genetic_type__name', },
            commodity: { name: '', field: 'deposit__main_commodity' },
            coreDepositor: { name: '', field: 'core_depositor__acronym' },
            fastSearch: '',
            page: 1,
            paginateBy: 25,
            orderBy: 'id'
          };
        this.drillcoreIdsFromMap = null;
        this.removeSessionStorage();
        console.log("AFTER");
        console.log(this.searchParameters);
      },

      removeSessionStorage() {
        this.$session.remove('drillcore');
        this.$session.remove('drillcoreIdsFromMap');
        this.$session.remove('drillcorePage');
        this.$session.remove('drillcorePaginateBy');
        this.$session.remove('drillcoreOrderBy');
      },

      addSessionStorage() {
        this.$session.set('drillcore', this.searchParameters);
        this.$session.set('drillcoreIdsFromMap', this.drillcoreIdsFromMap);
        if (this.drillcoreIdsFromMap != null) {
          this.$session.set('drillcorePage', this.searchParameters.page);
          this.$session.set('drillcorePaginateBy', this.searchParameters.paginateBy);
          this.$session.set('drillcoreOrderBy', this.searchParameters.orderBy);
        } else {
          this.$session.remove('drillcorePage');
          this.$session.remove('drillcorePaginateBy');
          this.$session.remove('drillcoreOrderBy');
        }
      },

      addFloatingTableHeaders() {
        $('#table-search').floatThead({
          position: 'absolute',
          zIndex: 1025,
          top: function () {
            return $('#main').css('padding-top') === '22px' ? 0 : 98;
          }
        });
      },

      reflowFloatThead() {
        $('#table-search').floatThead('reflow');
      },

      toastInfo(text) {
        this.$toast.info(text, 'Info', {
          position: 'bottomRight',
          timeout: 3000,
          pauseOnHover: false
        })
      },



      /*****************************
       *****  MAP CODE START  ******
       *****************************/

      getMapData() {
        this.$http.get(this.API_URL + 'drillcore/', {params: {format: 'json', paginate_by: 1000, fields: 'id,name,longitude,latitude'}}).then(response => {
          console.log(response);
          if (response.status === 200) {
            this.mapResponse.count = response.body.count;
            this.mapResponse.results = response.body.results;
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      initMap() {
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
        this.map.addControl(new ScaleLine());
        // this.addAllPoints(this.mapResponse.results);
        this.addPointerMoveInteraction();
        this.addSelectInteraction(this);
      },

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

      addSelectInteraction(myComponent) {
        let select = new Select({
          multi: true,
        });
        this.select = select;
        let selectedFeatures = this.select.getFeatures();

        let allDrillcores = myComponent.allVectors;
        let allFeatures = allDrillcores.getFeatures();

        this.map.addInteraction(this.select);

        /*** ONE CLICK SELECT ***/
        this.select.on("select", function () {

          // STYLES ALL POINTS TO GREEN BEFORE NEW SELECT
          allDrillcores.getFeatures().forEach(function (feature) {
            feature.setStyle(new Style({
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
                text: feature.get('name'),
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
          });

          let drillcoreIds = [];

          selectedFeatures.getArray().map(function (feature) {
            drillcoreIds.push(feature.getId().toString());
            feature.setStyle(new Style({
              image: new Circle({
                radius: 7,
                fill: new Fill({ color: '#CD154F' }),
                stroke: new Stroke({
                  color: 'black',
                  width: 1
                })
              }),
              zIndex: 100,
              text: new Text({
                scale: 0,
                text: feature.get('name'),
                offsetY: -25,
                fill: new Fill({
                  color: 'black'
                }),
                stroke: new Stroke({
                  color: 'white',
                  width: 3.5
                })
              })
            }))
          });

          if (drillcoreIds.length > 0) {
            myComponent.drillcoreIdsFromMap = drillcoreIds
          }
        });

        let dragBox = new DragBoxInteraction();
        this.map.addInteraction(dragBox);

        /*** DRAGBOX SELECT ***/
        dragBox.on('boxend', function () {

          // STYLES ALL POINTS TO GREEN BEFORE NEW SELECT
          allDrillcores.getFeatures().forEach(function (feature) {
            feature.setStyle(new Style({
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
                text: feature.get('name'),
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
          });

          let drillcoreIds = [];

          selectedFeatures.clear();
          let extent = dragBox.getGeometry().getExtent();
          allDrillcores.forEachFeatureIntersectingExtent(extent, function (feature) {
            selectedFeatures.push(feature);
            drillcoreIds.push(feature.getId().toString());
            feature.setStyle(new Style({
              image: new Circle({
                radius: 7,
                fill: new Fill({ color: '#CD154F' }),
                stroke: new Stroke({
                  color: 'black',
                  width: 1
                })
              }),
              zIndex: 100,
              text: new Text({
                scale: 0,
                text: feature.get('name'),
                offsetY: -25,
                fill: new Fill({
                  color: 'black'
                }),
                stroke: new Stroke({
                  color: 'white',
                  width: 3.5
                })
              })
            }))
          });

          if (drillcoreIds.length > 0) {
            myComponent.drillcoreIdsFromMap = drillcoreIds
          }
        });
      },

      addAllPoints(results) {
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

      resetPointColor(allVectors) {
        let allFeatures = allVectors.getFeatures();
        for (let feature in allFeatures) {
          allFeatures[feature].setStyle(new Style({
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
              text: allFeatures[feature].get('name'),
              offsetY: -25,
              fill: new Fill({
                color: 'black'
              }),
              stroke: new Stroke({
                color: 'white',
                width: 3.5
              })
            })
          }))
        }
      },

      updatePointColor(results, allVectors) {
        const allFeatures = allVectors.getFeatures();

        for (const result in results) {

          for (const feature in allFeatures) {

            if (results[result].id === allFeatures[feature].getId()) {
              allFeatures[feature].setStyle(new Style({
                image: new Circle({
                  radius: 7,
                  fill: new Fill({ color: '#CD154F' }),
                  stroke: new Stroke({
                    color: 'black',
                    width: 1
                  })
                }),
                zIndex: 101,
                text: new Text({
                  scale: 0,
                  text: allFeatures[feature].get('name'),
                  offsetY: -25,
                  fill: new Fill({
                    color: 'black'
                  }),
                  stroke: new Stroke({
                    color: 'white',
                    width: 3.5
                  })
                })
              }))
            }
          }

        }

      },

      colorMapPointsUsingIds(drillcoreIds, allVectors) {
        const allFeatures = allVectors.getFeatures();

        for (const id in drillcoreIds) {

          for (const feature in allFeatures) {

            if (parseInt(drillcoreIds[id]) === allFeatures[feature].getId()) {
              allFeatures[feature].setStyle(new Style({
                image: new Circle({
                  radius: 7,
                  fill: new Fill({ color: '#CD154F' }),
                  stroke: new Stroke({
                    color: 'black',
                    width: 1
                  })
                }),
                zIndex: 101,
                text: new Text({
                  scale: 0,
                  text: allFeatures[feature].get('name'),
                  offsetY: -25,
                  fill: new Fill({
                    color: 'black'
                  }),
                  stroke: new Stroke({
                    color: 'white',
                    width: 3.5
                  })
                })
              }))
            }

          }

        }

      }

      /*****************************
       *****   MAP CODE END   ******
       *****************************/



    }
  }
</script>

<style scoped>
  .searchButtons {
    margin: 0.75rem 0;
  }

  .map {
    height: 400px;
    min-width: 300px;
    width: 100%;
  }

  span {
    white-space: nowrap;
  }
</style>
