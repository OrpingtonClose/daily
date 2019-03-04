import React from 'react';
import { render } from 'react-dom';
import Application from './components/Application';

//hot reload dosen't work...
//import { AppContainer } from 'react-hot-loader';

// const Application = () => {
//     return (
//         <div>
//             <h1>Hello world!</h1>
//             <button className="full-width">
//                 This button does not do anything.
//             </button>
//         </div>
//     )
// }

//render(<Application />, document.getElementById("application"));

render(<Application />, document.getElementById("application"));
//hot reload dosen't work...
// const renderApplication = async () => {
//     const { default: Application } = await import("./components/Application");
//     render(
//       <AppContainer>
//         <Application />
//       </AppContainer>, document.getElementById("application"));
// };

// renderApplication();

// if (module.hot) { 
//     module.hot.accept(renderApplication); 
// }