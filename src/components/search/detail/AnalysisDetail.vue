<template>
  <div class="analysis-detail">

    <spinner v-if="isSearching" class="loading-overlay" size="huge" message="Loading data..."></spinner>

    <div v-if="analysis != null">

      <div class="row">
        <div class="col">
          <h2 v-if="analysis[0].analysis_method__method !== 'CT'">Analysis ID: {{id}}</h2>
          <h2 v-else>CT scan: {{id}}</h2>
        </div>
      </div>


      <div class="row">
        <div class="col-md-6">
          <b-tabs pills>
            <b-tab :title="analysis[0].analysis_method__method !== 'CT' ? 'Analysis details' : 'CT details'">
              <table class="table table-bordered table-hover th-styles mt-2">
                <tr v-if="analysis[0].id">
                  <td>ID</td>
                  <td>{{analysis[0].id}}</td>
                </tr>

                <tr v-if="analysis[0].drillcore__name">
                  <td>Drillcore</td>
                  <td>
                    <!--<router-link :to="{ path: '/drillcore/' + analysis[0].drillcore__id }">{{analysis[0].drillcore__name}}</router-link>-->
                    <a href="javascript:void(0)"
                       @click="openInNewWindow({object: 'drillcore', id: analysis[0].drillcore__id})">
                      {{analysis[0].drillcore__name}}
                    </a>
                  </td>
                </tr>

                <tr v-if="analysis[0].sample__sample_number">
                  <td>Sample</td>
                  <td>
                    <a href="javascript:void(0)"
                       @click="openInNewWindow({object: 'sample', id: analysis[0].sample__id})">{{analysis[0].sample__sample_number}}</a>
                    <!--<router-link target="_" :to="{ path: '/sample/' + analysis[0].sample__id }">{{analysis[0].sample__sample_number}}</router-link>-->
                  </td>
                </tr>

                <tr v-if="analysis[0].depth">
                  <td>Depth from (m)</td>
                  <td>{{analysis[0].depth}}</td>
                </tr>

                <tr v-if="analysis[0].end_depth">
                  <td>Depth to (m)</td>
                  <td>{{analysis[0].end_depth}}</td>
                </tr>

                <tr v-if="this.drillcoreDiameter && analysis[0].analysis_method__method === 'CT'">
                  <td>Core diameter (mm)</td>
                  <td>{{this.drillcoreDiameter[0].diameter}}</td>
                </tr>

                <tr v-if="analysis[0].analysis_method__method">
                  <td>Method</td>
                  <td>
                    {{analysis[0].analysis_method__method}}
                    <span v-if="analysis[0].analysis_method__remarks">
                      ({{ analysis[0].analysis_method__remarks }})
                    </span>
                  </td>
                </tr>

                <tr v-if="analysis[0].lab__lab">
                  <td>Lab</td>
                  <td>{{analysis[0].lab__lab}}</td>
                </tr>

                <tr v-if="analysis[0].instrument__instrument">
                  <td>Instrument</td>
                  <td>{{analysis[0].instrument__instrument}}</td>
                </tr>

                <tr v-if="analysis[0].instrument__model">
                  <td>Instrument model</td>
                  <td>{{analysis[0].instrument__model}}</td>
                </tr>

                <tr v-if="analysis[0].analytical">
                  <td>Analytical procedures & conditions</td>
                  <td>{{analysis[0].analytical}}</td>
                </tr>

                <tr v-if="analysis[0].refs">
                  <td>Reference sample(s) or standard(s)</td>
                  <td>{{analysis[0].refs}}</td>
                </tr>

                <tr v-if="analysis[0].postProccessing">
                  <td>Post-proccessing</td>
                  <td>{{analysis[0].postProccessing}}</td>
                </tr>

                <tr v-if="analysis[0].agent__acronym && analysis[0].agent__parent__acronym">
                  <td>Analyzed by</td>
                  <td>{{analysis[0].agent__acronym}}, {{analysis[0].agent__parent__acronym}}</td>
                </tr>

                <tr v-if="analysis[0].date">
                  <td>Date</td>
                  <td>{{analysis[0].date | formatDate}}</td>
                </tr>
              </table>
            </b-tab>

            <b-tab v-if="acquisitionParams" title="Acquisition parameters">
              <table class="table table-bordered table-hover th-styles mt-2">

                <tr v-for="(value, key) in  acquisitionParams">
                  <td>{{key}}</td>
                  <td style="white-space: nowrap;">{{value}}</td>
                </tr>

              </table>
            </b-tab>
          </b-tabs>

          <div class="row">
            <div class="col" v-if="attachmentDataFiles.length > 0">
              <h3>Stacked images</h3>

              <p>Tiff stacks are for image viewers that can handle layered tiff's, e.g.
                <a target="_blank" href="https://imagej.nih.gov/ij/">ImageJ</a>.
                Caution: all data will be loaded into memory.
              </p>

              <p>Tiff with tiles is for
                <a target="_blank" href="http://www.thygraphics.com">ImageView2D</a>
                (recommended but for Windows only). Low memory usage, switching of view orientation.
              </p>

              <table class="table table-bordered table-hover th-styles">
                <tr v-for="entity in attachmentDataFiles">
                  <td>{{ entity.title }} ({{ entity.filesize }})</td>
                  <td class="text-center">
                    <a title="Open original" href="javascript:void(0)"
                       @click="openUrlInNewWindow({url: helper.getFileLink({filename: entity.filename})})">
                      <font-awesome-icon :icon="faFile" size="2x"/>
                    </a>
                  </td>
                  <!-- TODO: Add download button -->
                </tr>
              </table>
            </div>
          </div>


          <div class="row">
            <div class="col">

              <div class="row" v-if="spectraCount > 0">
                <div class="col">
                  <a class="btn btn-primary mb-3" href="javascript:void(0)"
                     @click="openInNewWindow({object: 'spectrum', id: id})">Show spectra ({{spectraCount}})</a>
                  <!--<router-link :to="{ path: '/spectrum/' + id }" class="btn btn-primary mb-3">Show spectra ({{spectraCount}})</router-link>-->
                </div>
              </div>

            </div>
          </div>

          <div class="row">
            <div class="col" v-if="analysisResults != null">
              <h3>Analysis results</h3>

              <div class="mb-2">
                <export-buttons filename="analysisResults"/>
              </div>

              <table id="table-search" class="table table-bordered table-hover">
                <thead class="thead-light">
                <tr class="th-sort">
                  <th>
                    <span v-if="analysisResults.length > 1" @click="changeOrder('parameter__parameter')">
                      <font-awesome-icon
                        v-if="analysisResultsOrder !== 'parameter__parameter' && analysisResultsOrder !== '-parameter__parameter'"
                        :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection"/>
                      Parameter
                    </span>
                    <div v-else>Parameter</div>
                  </th>
                  <th>Unit</th>
                  <th>
                    <span v-if="analysisResults.length > 1" @click="changeOrder('value')">
                      <font-awesome-icon v-if="analysisResultsOrder !== 'value' && analysisResultsOrder !== '-value'"
                                         :icon="icon"/>
                      <font-awesome-icon v-else :icon="sortingDirection"/>
                      Value
                    </span>
                    <div v-else>Value</div>
                  </th>
                  <th>Error</th>
                  <th>LOD</th>
                </tr>
                </thead>

                <tbody>
                <tr v-for="analysisResult in analysisResults">
                  <td>{{analysisResult.parameter__parameter}}</td>
                  <td>{{analysisResult.unit__unit}}</td>
                  <td>{{analysisResult.value}} {{analysisResult.value_txt}}</td>
                  <td>{{analysisResult.value_error}}</td>
                  <td>{{analysisResult.lower_limit}}</td>
                </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- IMAGES, VIDEOS and DATA FILES -->
        <div class="col-md-6">

          <div class="row">

            <div class="col" v-if="attachmentImages.length > 0">
              <h3>Cross-sections</h3>

              <div class="vs-component vs-images vs-images-hover-default">
                <ul class="vs-ul-images vs-images--ul">
                  <li class="vs-image custom-size" v-for="(entity, index) in attachmentImages">
                    <div class="con-vs-image" :id="'icon-' + index">


                      <a data-fancybox="slices"
                         v-if="entity.filename !== null"
                         :href="helper.getFileLink({filename: entity.filename})"
                         :data-caption="setCaption({title: entity.title, description: entity.description})">

                        <!-- Todo: Get thumbnails working for data-fancybox (old has because of <img/> tag) -->

                        <div class="vs-image--img"
                             v-if="entity.filename.endsWith('png') || entity.filename.endsWith('jpg') || entity.filename.endsWith('jpeg') || entity.filename.endsWith('svg')"
                             :style="'background-image: url(' + helper.getFileLink({size: 'small', filename: entity.filename}) + ')'"></div>

                        <div v-else class="vs-image--img no-image"><!-- Unsupported format --></div>
                      </a>

                      <div class="vs-image--img no-image" v-if="entity.filename === null">
                        <!-- Filename missing --></div>
                    </div>

                    <b-tooltip :target="'icon-' + index" placement="auto">{{ entity.title }}</b-tooltip>
                  </li>
                </ul>
              </div>


              <!-- Old and not best -->
              <!--              <div class="row">-->
              <!--                <div class="col-4 text-center mb-2" v-for="(entity, index) in attachmentImages"-->
              <!--                     v-if="entity.filename.endsWith('png') || entity.filename.endsWith('jpg') || entity.filename.endsWith('jpeg') || entity.filename.endsWith('svg')">-->

              <!--                  <a data-fancybox="slices-old" :href="helper.getFileLink({size: 'large', filename: entity.filename})"-->
              <!--                     :data-caption="setCaption({title: entity.title, description: entity.description})">-->
              <!--                    <img :id="'icon-' + index"-->
              <!--                         :src="helper.getFileLink({size: 'small', filename: entity.filename})"-->
              <!--                         class="img-fluid img-thumbnail"/>-->
              <!--                  </a>-->

              <!--                  <b-tooltip :target="'icon-' + index" placement="auto">{{ entity.title }}</b-tooltip>-->

              <!--                </div>-->
              <!--              </div>-->


            </div>
          </div>

          <div class="row">
            <div class="col-12 mt-2" v-if="attachmentVideos.length > 0">
              <h3>Videos</h3>

              <div class="row">
                <div class="col-12 mt-3" v-for="entity in attachmentVideos"
                     v-if="entity.filename.endsWith('mp4') | entity.filename.endsWith('webm') || entity.filename.endsWith('gif')">

                  <video width="100%" controls loop>
                    <source :src="helper.getFileLink({filename: entity.filename})" type="video/mp4">
                  </video>
                  <p class="h5 text-left pl-2">{{ entity.title }}</p>
                  <p class="h6 text-left pl-2">{{ entity.description }}</p>

                </div>
              </div>

            </div>
          </div>

        </div>

      </div>

    </div>

    <div v-else>
      <div v-if="!isSearching">
        Sorry but we didn't find any results!
        Check your id <b>{{id}}</b>
      </div>
    </div>

  </div>
</template>

<script>
  import Spinner from 'vue-simple-spinner'
  import FontAwesomeIcon from '@fortawesome/vue-fontawesome'
  import faSort from '@fortawesome/fontawesome-free-solid/faSort'
  import faSortUp from '@fortawesome/fontawesome-free-solid/faSortUp'
  import faSortDown from '@fortawesome/fontawesome-free-solid/faSortDown'
  import faFile from '@fortawesome/fontawesome-free-regular/faFile'
  import ExportButtons from './partial/ExportButtons'
  import helper from '@/assets/js/helper'

  export default {
    components: {
      Spinner,
      FontAwesomeIcon,
      ExportButtons
    },
    props: ['id'],
    name: "analysis-detail",
    data() {
      return {
        API_URL: 'https://api.eurocore.rocks/analysis/',
        isSearching: false,
        helper: helper,
        analysis: null,
        analysisResults: null,
        analysisResultsOrder: 'parameter__parameter',
        spectraCount: 0,
        attachmentImages: [],
        attachmentVideos: [],
        attachmentDataFiles: [],
        drillcoreDiameter: null,
        acquisitionParams: [],
      }
    },
    metaInfo() {
      return {
        title: 'EUROCORE Data Portal: Analysis ' + this.id
      }
    },
    computed: {
      icon() {
        return faSort;
      },

      faFile() {
        return faFile
      },

      sortingDirection() {
        return this.analysisResultsOrder.includes('-') ? faSortDown : faSortUp
      },
    },
    created: function () {
      this.resetData();
      this.getAnalysisById(this.id);
      this.getAnalysisResultById(this.id);
      this.getSpectraCount(this.id);
      this.getAnalysisAttachments(this.id, 'image')
      this.getAnalysisAttachments(this.id, 'video')
      this.getAnalysisAttachments(this.id, 'data file')
    },
    updated: function () {
      $('[data-fancybox="slices"]').fancybox({
        loop: true,
        buttons: [
          'slideShow',
          'fullScreen',
          'thumbs',
          'share',
          'arrowLeft',
          'arrowRight',
          'close'
        ],
        thumbs: {
          autoStart: true
        },
        transitionEffect: "slide",
      });
    },
    watch: {
      'id': function () {
        this.resetData();
        this.getAnalysisById(this.id);
        this.getAnalysisResultById(this.id);
        this.getSpectraCount(this.id);
        this.getAnalysisAttachments(this.id, 'image')
        this.getAnalysisAttachments(this.id, 'video')
        this.getAnalysisAttachments(this.id, 'data file')
      },
      'analysisResultsOrder': function () {
        this.getAnalysisResultById(this.id);
      },
      'analysis': function (newVal, oldVal) {
        if (typeof newVal !== 'undefined' && newVal !== null && newVal.length > 0) {
          this.acquisitionParams = this.sortAcquisitionParameters(newVal[0].acquisition_params);
        }

        if (newVal == null) {
          $('body')[0].setAttribute('class', 'background-color-white')
        } else {
          $('body')[0].removeAttribute('class')
        }
      }
    },
    methods: {
      getAnalysisById(id) {
        this.isSearching = true
        this.$http.get(this.API_URL + id, {params: {format: 'json'}}).then(response => {
          this.isSearching = false
          console.log(response);
          if (response.status === 200) {
            this.analysis = response.body.results;
            if (typeof this.analysis !== 'undefined') {
              this.getDrillcoreDiameter(this.analysis[0])
            }
          }
        }, errResponse => {
          this.isSearching = false
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      getAnalysisResultById(id) {
        this.$http.get('https://api.eurocore.rocks/analysis_result/', {
          params: {
            analysis__id: id,
            order_by: this.analysisResultsOrder,
            format: 'json'
          }
        }).then(response => {
          console.log(response);
          if (response.status === 200) {
            this.analysisResults = response.body.results;
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      getSpectraCount(id) {
        this.$http.get('https://api.eurocore.rocks/spectrum/', {
          params: {
            analysis__id: id,
            fields: 'id',
            format: 'json'
          }
        }).then(response => {
          console.log(response);
          if (response.status === 200) {
            this.spectraCount = response.body.count;
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      getAnalysisAttachments(id, type) {
        let url = 'https://api.eurocore.rocks/attachment/?analysis__id=' + id + '&order_by=title&format=json'
        if (type === 'image') url += '&attachment_type__value__icontains=image'
        else if (type === 'video') url += '&attachment_type__value__icontains=video'
        else if (type === 'data file') url += '&attachment_type__value__icontains=data file'

        this.$http.get(url).then(response => {
          console.log(response)
          if (response.status === 200) {
            if (response.body.count > 0) {
              if (type === 'image') this.attachmentImages = response.body.results
              else if (type === 'video') this.attachmentVideos = response.body.results
              else if (type === 'data file') this.attachmentDataFiles = response.body.results
            } else {
              if (type === 'image') this.attachmentImages = []
              else if (type === 'video') this.attachmentVideos = []
              else if (type === 'data file') this.attachmentDataFiles = []
            }
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      getDrillcoreDiameter(params) {
        this.$http.get('https://api.eurocore.rocks/drillcore_diameter/', {
          params: {
            drillcore__id: params.drillcore__id,
            start_depth__lte: params.depth,
            end_depth__gte: params.end_depth,
            fields: 'diameter',
            format: 'json'
          }
        }).then(response => {
          console.log(response)
          if (response.status === 200) {
            if (response.body.count > 0) {
              this.drillcoreDiameter = response.body.results
            }
          }
        }, errResponse => {
          console.log('ERROR: ' + JSON.stringify(errResponse));
        })
      },

      changeOrder(orderValue) {
        if (this.analysisResultsOrder === orderValue) {
          if (orderValue.charAt(0) !== '-') {
            orderValue = '-' + orderValue;
          } else {
            orderValue = orderValue.substring(1);
          }
        }
        this.analysisResultsOrder = orderValue;
      },

      setCaption(params) {
        let caption = ''
        if (params.title !== null) {
          caption += '<b>Title:</b> ' + params.title + '<br>'
        }
        if (params.description !== null) {
          caption += '<b>Description:</b> ' + params.description + '<br>'
        }
        return caption
      },

      openInNewWindow(params) {
        if (typeof (params.width) === 'undefined') {
          params.width = 800;
        }
        window.open(location.origin + '/#/' + params.object + '/' + params.id, '', 'width=' + params.width + ', height=750');
      },

      openUrlInNewWindow(params) {
        if (typeof (params.width) === 'undefined') {
          params.width = 800;
        }
        window.open(params.url, '', 'width=' + params.width + ', height=750');
      },

      sortAcquisitionParameters(parameters) {
        if (parameters !== null) {
          const orderedParams = {};

          Object.keys(parameters).sort().forEach(function (key) {

            // Sorting using this order: #72
            orderedParams['voltage'] = parameters['voltage']
            orderedParams['prefilter'] = parameters['prefilter']
            orderedParams['tube current'] = parameters['tube current']
            orderedParams['exposure time per projection'] = parameters['exposure time per projection']
            orderedParams['number of projections'] = parameters['number of projections']
            orderedParams['facility'] = parameters['facility']
            orderedParams['lateral voxel size'] = parameters['lateral voxel size']
            orderedParams['axial voxel size'] = parameters['axial voxel size']
            orderedParams['grey value of     0 corresponds to attenuation coefficient'] = parameters['grey value of     0 corresponds to attenuation coefficient']
            orderedParams['grey value of 65535 corresponds to attenuation coefficient'] = parameters['grey value of 65535 corresponds to attenuation coefficient']
          });

          return orderedParams
        }
        return parameters
      },

      resetData() {
        this.analysis = null;
        this.analysisResults = null;
        this.analysisResultsOrder = 'parameter__parameter';
        this.spectraCount = 0;
        this.drillcoreDiameter = null;
        this.acquisitionParams = [];
      }
    }
  }
</script>

<style scoped>
  h3 {
    color: #6bb745;
  }

  .th-sort > th > span {
    cursor: pointer;
  }

  .th-sort > th > span:hover {
    color: #000;
  }

  /* This makes images come 3 in a row */
  .vs-image {
    width: calc(33% - 4px);
  }

  /* Makes image nicer, does not zoom in */
  .vs-image--img {
    background-size: cover;
  }

  /* EXTRA SMALL DEVICES */
  @media (max-width: 575.98px) {
    .img-thumbnail {
      max-height: 140px;
      max-width: 95px;
    }
  }

  /* SMALL DEVICES */
  @media (min-width: 576px) and (max-width: 767.98px) {
    .img-thumbnail {
      max-height: 200px;
      max-width: 170px;
    }
  }

  /* MEDIUM DEVICES */
  @media (min-width: 768px) and (max-width: 991.98px) {
    .img-thumbnail {
      max-height: 150px;
      max-width: 100px;
    }
  }

  /* MEDIUM DEVICES */
  @media (min-width: 768px) and (max-width: 991.98px) {
    .img-thumbnail {
      max-height: 150px;
      max-width: 100px;
    }
  }

  /* LARGE DEVICES */
  @media (min-width: 992px) and (max-width: 1199.98px) {
    .img-thumbnail {
      max-height: 150px;
      max-width: 150px;
    }
  }

  /* EXTRA LARGE DEVICES */
  @media (min-width: 1200px) {
    .img-thumbnail {
      max-height: 200px;
      max-width: 175px;
    }
  }
</style>
