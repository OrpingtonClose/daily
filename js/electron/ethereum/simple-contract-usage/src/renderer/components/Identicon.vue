<template>
    <canvas ref="my-canvas"></canvas>
</template>

<script>
    var randseed = new Array(4); 
    function seedrand(seed) {
        for (var i = 0; i < randseed.length; i++) {
            randseed[i] = 0;
        }
        for (var i = 0; i < seed.length; i++) {
            randseed[i%4] = ((randseed[i%4] << 5) - randseed[i%4]) + seed.charCodeAt(i);
        }
    }

    function rand() {
        // based on Java's String.hashCode(), expanded to 4 32bit values
        var t = randseed[0] ^ (randseed[0] << 11);
        randseed[0] = randseed[1];
        randseed[1] = randseed[2];
        randseed[2] = randseed[3];
        randseed[3] = (randseed[3] ^ (randseed[3] >> 19) ^ t ^ (t >> 8));
        return (randseed[3]>>>0) / ((1 << 31)>>>0);
    }

    function createColor() {
        var h = Math.floor(rand() * 360);
        var s = ((rand() * 60) + 40) + '%';
        var l = ((rand()+rand()+rand()+rand()) * 25) + '%';
        var color = 'hsl(' + h + ',' + s + ',' + l + ')';
        return color;
    }

    function createImageData(size) {
        var width = size;
        var height = size;
        var dataWidth = Math.ceil(width / 2);
        var mirrorWidth = width - dataWidth;
        var data = [];
        for(var y = 0; y < height; y++) {
            var row = [];
            for(var x = 0; x < dataWidth; x++) {
                row[x] = Math.floor(rand()*2.3);
            }
            var r = row.slice(0, mirrorWidth);
            r.reverse();
            row = row.concat(r);
            for(var i = 0; i < row.length; i++) {
                data.push(row[i]);
            }
        }
        return data;
    }

    function drawOnCanvas(seed, size, scale, c) {
        seedrand(seed);

        var color = createColor();
        var bgcolor = createColor();
        var spotcolor = createColor();
        var imageData = createImageData(size);

        var width = Math.sqrt(imageData.length);
        c.height = width * scale;
        c.width = width * scale;

        var cc = c.getContext('2d');
        cc.fillStyle = bgcolor;
        cc.fillRect(0, 0, c.width, c.height);
        cc.fillStyle = color;

        for(var i = 0; i < imageData.length; i++) {
            var row = Math.floor(i / width);
            var col = i % width;

            cc.fillStyle = (imageData[i] == 1) ? color : spotcolor;
            if(imageData[i]) {
                cc.fillRect(col * scale, row * scale, scale, scale);
            }
        }
    }
    export default {
        name: 'identicon',
        props: {
            identity: {
                type: String,
                required: true
            },
            size: {
                type: Number,
                default: 8,
                validator: value => Math.floor(value) === value     
            },
            scale: {
                type: Number,
                default: 4,
                validator: value => Math.floor(value) === value     
            }
        },
        mounted() {            
            drawOnCanvas(this.identity, this.size, this.scale, this.$refs["my-canvas"]);
        }
    }
</script>

<style scope>
</style>
