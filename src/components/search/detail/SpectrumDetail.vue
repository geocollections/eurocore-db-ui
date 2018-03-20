<template>
  <div v-if="spectrumData.count > 0">
    <div class="row">
      <div class="col">
        <h2>Spectrum</h2>
        <h3>Analysis ID: {{analysisId}}</h3>
      </div>
    </div>

    <div class="row">
      <div class="col">
        <div ref="spectrumGraph" id="graph">
          <!--Graph is drawn here-->
        </div>
      </div>
    </div>
  </div>
  <div v-else>
    Sorry but we didn't find any results!
    Check your id <b>{{analysisId}}</b>
  </div>
</template>

<script>
  export default {
    props: ['analysisId'],
    name: "spectrum-detail",
    data() {
      return {
        spectrumData: { count: 0, results: [] }
      }
    },
    watch: {
      'analysisId': function () {
        this.resetData();
        this.getSpectrumResultsById(this.analysisId);
      }
    },
    created: function () {
      this.getSpectrumResultsById(this.analysisId);
    },
    updated: function () {
      if (this.spectrumData.count > 0) {
        this.filterSpectrumData(this.spectrumData.results);
      }
    },
    methods: {
      getSpectrumResultsById(id) {
        this.$http.jsonp('https://api.eurocore.rocks/spectrum/', {params: {analysis__id: id, format: 'jsonp'}}).then(response => {
          console.log(response);
          if (response.status === 200) {
            this.spectrumData.count = response.body.count;
            this.spectrumData.results = response.body.results;
          }
        }, errResponse => {
          console.log('ERROR: ');
          console.log(errResponse);
          console.log(errResponse.status);
        })
      },

      resetData() {
        this.spectrumData = { count: 0, results: [] }
      },

      filterSpectrumData(results) {
        let data = [];
        for (let k = 0; k < results.length; k++) {
          let x = [];
          let y = [];
          let t = {
            x,
            y,
            type: 'scattergl',
            name: results[k]['energy_range__value']
          };

          for (let i = 0; i < results[k]['data'].length; i++) {
            x.push(results[k]['data'][i].keV);
            y.push(results[k]['data'][i].count);
          }
          data.push(t);
        }

        let layout = {
          showlegend: true,
          margin: {
            /* l: 40,
             r: 10,
             b: 40,
             t: 40,
             pad: 4*/
            l: 10,
            r: 10,
            b: 40,
            t: 120,
            pad: 4
          },
          title: 'Analysis ID: '+ this.analysisId,
          legend: {
            x: 0,
            y: 1.1,
            "orientation": "h",
          },
          xaxis: {
            title: 'keV',
            domain: [0.05, 0.95],
            linecolor: 'black',
            linewidth: 1,
            // mirror: true,
            autotick: true,
            ticks: "outside",
            ticklen: 5,
            tickwidth: 1,
            tickcolor: 'black'
          },
          yaxis: {
            title: 'count',
            linecolor: 'black',
            linewidth: 1,
            // mirror: true,
            autotick: true,
            ticks: "outside",
            ticklen: 5,
            tickwidth: 1,
            tickcolor: 'black'
          }
        };

        let d3 = Plotly.d3;

        let WIDTH_IN_PERCENT_OF_PARENT = 90,
          HEIGHT_IN_PERCENT_OF_PARENT = 70;
        let gd3 = d3.select(this.$refs.spectrumGraph)
        // let gd3 = d3.select("div[id='graph']")
        //.append('div')
          .style({
            width: WIDTH_IN_PERCENT_OF_PARENT + '%',
            'margin-left': (100 - WIDTH_IN_PERCENT_OF_PARENT) / 2 + '%',

            height: HEIGHT_IN_PERCENT_OF_PARENT + 'vh',
            'margin-top': 0
          });

        let gd = gd3.node();

        Plotly.newPlot(gd, data, layout,
          {
            modeBarButtonsToRemove: ['toImage'],
            modeBarButtonsToAdd: [{
              name: 'Download plot as a SVG',
              icon: Plotly.Icons.camera,
              click: function (gd) {
                Plotly.downloadImage(gd, {filename: "spectrum", format: 'svg',height: 600, width: 900 })
              }
            }],
            displaylogo: false
          });

        window.onresize = function() {
          Plotly.Plots.resize(gd);
        };
      }
    }
  }
</script>

<style scoped>
  h3 {
    color: #6bb745;
  }
</style>