//https://js.tensorflow.org/setup/
//npm install @tensorflow/tfjs
//npm install @tensorflow/tfjs-node #native bindings
//npm install @tensorflow/tfjs-node-gpu
const tf = require("@tensorflow/tfjs-node");
const _ = require("lodash");
const shape = [2, 3];
const data = [_.range(1, 4), 
              _.range(1, 4).map(n=>n*10)];

tf.tensor(_.flatten(data), shape).print();
tf.tensor(data).print();
tf.tensor2d(data).print();
tf.zeros(shape).print();
tf.ones(shape).print();

const init = tf.zeros([5]);
const biases = tf.variable(init);
biases.print();

const updatedValues = tf.tensor1d(_.range(5).map((v, i) => i % 2));
biases.assign(updatedValues);
biases.print();

tf.tensor((a => [a, a.map(n=>n*10), a.map(n=>n*100)])(_.range(1, 6))).square().print();

const data1 = [[1.0, 2.0], [3.0, 4.0]];
const data2 = [[5.0, 6.0], [7.0, 8.0]];
var [t1, t2] = [data1, data2].map(d => tf.tensor2d(d));

t1.add(t2).print()
t1.mul(t2).print()
t1.sub(t2).square().print()
tf.square(tf.sub(t2, t1)).print()

function predict(input) {
    return tf.tidy(()=>{
        const x = tf.scalar(input);
        const ax2 = a.mul(x.square());
        const bx = b.mul(x);
        const y = ax2.add(bx).add(c);
        return y;
    });
}

const constants = [2, 4, 8].map(_.ary(tf.scalar, 1));
const [a, b, c] = constants;

predict(3).print();

// var layer = tf.layers.simpleRNN({
//     units: 20,
//     reccurentInitializer: 'GlorotNormal',
//     inputShape: [80, 4]
// });
//https://github.com/tensorflow/tfjs-examples/blob/master/getting-started/index.js
async function run() { 
    var model = tf.sequential();
    var layer = tf.layers.dense({units: 1, inputShape: [1]});
    //var toCompile = {optimizer: 'sgd', loss: "categoricalCrossentropy"};
    var toCompile = {optimizer: 'sgd', loss: 'meanSquaredError'};
    model.add(layer);
    model.compile(toCompile);

    //var [xs, ys] = [[-1, 0, 1, 2, 3, 4],[-3, -1, 1, 3, 5, 7]
    //            ].map(_.ary(_.partial(tf.tensor2d, _, [6, 1]),1));
    var xs = tf.tensor2d([-1, 0, 1, 2, 3, 4], [6, 1]);
    var ys = tf.tensor2d([-3, -1, 1, 3, 5, 7], [6, 1]);
    //model.fit({x: tf.ones([80,4]), y: ["labels1", "labels2", "labels3", "labels4"]}).then(console.log);
    await model.fit(xs, ys, {epochs: 250});
    console.log(`===============================`);
    console.log(model.predict(tf.tensor2d([20], [1, 1])).dataSync());
    console.log(`===============================`);
}

run();


tf.tensor2d([1, 1, 0, 0], [2,2], 'bool').all(1).print();