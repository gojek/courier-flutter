"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[632],{3905:(e,t,r)=>{r.d(t,{Zo:()=>u,kt:()=>d});var n=r(7294);function o(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function a(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function i(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?a(Object(r),!0).forEach((function(t){o(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):a(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function s(e,t){if(null==e)return{};var r,n,o=function(e,t){if(null==e)return{};var r,n,o={},a=Object.keys(e);for(n=0;n<a.length;n++)r=a[n],t.indexOf(r)>=0||(o[r]=e[r]);return o}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(n=0;n<a.length;n++)r=a[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(o[r]=e[r])}return o}var l=n.createContext({}),c=function(e){var t=n.useContext(l),r=t;return e&&(r="function"==typeof e?e(t):i(i({},t),e)),r},u=function(e){var t=c(e.components);return n.createElement(l.Provider,{value:t},e.children)},p="mdxType",f={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},m=n.forwardRef((function(e,t){var r=e.components,o=e.mdxType,a=e.originalType,l=e.parentName,u=s(e,["components","mdxType","originalType","parentName"]),p=c(r),m=o,d=p["".concat(l,".").concat(m)]||p[m]||f[m]||a;return r?n.createElement(d,i(i({ref:t},u),{},{components:r})):n.createElement(d,i({ref:t},u))}));function d(e,t){var r=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var a=r.length,i=new Array(a);i[0]=m;var s={};for(var l in t)hasOwnProperty.call(t,l)&&(s[l]=t[l]);s.originalType=e,s[p]="string"==typeof e?e:o,i[1]=s;for(var c=2;c<a;c++)i[c]=r[c];return n.createElement.apply(null,i)}return n.createElement.apply(null,r)}m.displayName="MDXCreateElement"},6223:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>l,contentTitle:()=>i,default:()=>p,frontMatter:()=>a,metadata:()=>s,toc:()=>c});var n=r(7462),o=(r(7294),r(3905));const a={},i=void 0,s={unversionedId:"Message QoS",id:"Message QoS",title:"Message QoS",description:"The Quality of Service (QoS) level is an agreement between the sender of a message and the receiver of a message that defines the guarantee of delivery for a specific message. There are 3 QoS levels in MQTT:",source:"@site/docs/Message QoS.md",sourceDirName:".",slug:"/Message QoS",permalink:"/courier-flutter/docs/Message QoS",draft:!1,editUrl:"https://github.com/gojek/courier-flutter/edit/main/docs/docs/Message QoS.md",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"Connection Lifeycle",permalink:"/courier-flutter/docs/Connection Lifeycle"},next:{title:"Subscribe & Receive Message",permalink:"/courier-flutter/docs/Subscribe & Receive Message"}},l={},c=[],u={toc:c};function p(e){let{components:t,...r}=e;return(0,o.kt)("wrapper",(0,n.Z)({},u,r,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("p",null,"The Quality of Service (QoS) level is an agreement between the sender of a message and the receiver of a message that defines the guarantee of delivery for a specific message. There are 3 QoS levels in MQTT:"),(0,o.kt)("ul",null,(0,o.kt)("li",{parentName:"ul"},"At most once (0)"),(0,o.kt)("li",{parentName:"ul"},"At least once (1)"),(0,o.kt)("li",{parentName:"ul"},"Exactly once (2).")),(0,o.kt)("p",null,"When you talk about QoS in MQTT, you need to consider the two sides of message delivery:"),(0,o.kt)("ul",null,(0,o.kt)("li",{parentName:"ul"},"Message delivery form the publishing client to the broker."),(0,o.kt)("li",{parentName:"ul"},"Message delivery from the broker to the subscribing client.")),(0,o.kt)("p",null,"You can read more about the detail of QoS in MQTT from ",(0,o.kt)("a",{parentName:"p",href:"https://www.hivemq.com/blog/mqtt-essentials-part-6-mqtt-quality-of-service-levels/"},"HiveMQ")," site."))}p.isMDXComponent=!0}}]);