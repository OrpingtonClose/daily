var sha256 = require("sha256")
var _ = require("lodash")

var multiHash = function(magnitude, msg) {
    var passes = Math.pow(10, magnitude);
    var passArray = _.range(passes);
    console.time();
    var result = passArray.reduce((prev, cur) => sha256(prev), msg || "dddd");
    console.timeEnd();
    return result;
}

multiHash(6)
//default: 5908.521ms
//'14cfa41f64d86d297a3f19a70ed440388013974df90adde6a603ca9ddc9f413f'

multiHash(3)
//default: 86.528ms
//'bf079c6f170a061d88c25aed3b2bd79948e1a559e6c5164f3084706e0aa6b362'

//RES=dddd
//for n in {1..1000}
//do RES=$(echo $RES | sha256sum - | awk '{print $1}')
//echo $RES
//done
//#????
//#dd6cdc26f92b18b899c30ab41e3da2664ace1d716d37a2dff0853747fec07045
