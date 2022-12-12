"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[450],{3905:(e,t,r)=>{r.d(t,{Zo:()=>c,kt:()=>f});var n=r(7294);function a(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function o(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function i(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?o(Object(r),!0).forEach((function(t){a(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):o(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function l(e,t){if(null==e)return{};var r,n,a=function(e,t){if(null==e)return{};var r,n,a={},o=Object.keys(e);for(n=0;n<o.length;n++)r=o[n],t.indexOf(r)>=0||(a[r]=e[r]);return a}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(n=0;n<o.length;n++)r=o[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(a[r]=e[r])}return a}var s=n.createContext({}),u=function(e){var t=n.useContext(s),r=t;return e&&(r="function"==typeof e?e(t):i(i({},t),e)),r},c=function(e){var t=u(e.components);return n.createElement(s.Provider,{value:t},e.children)},p="mdxType",m={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},d=n.forwardRef((function(e,t){var r=e.components,a=e.mdxType,o=e.originalType,s=e.parentName,c=l(e,["components","mdxType","originalType","parentName"]),p=u(r),d=a,f=p["".concat(s,".").concat(d)]||p[d]||m[d]||o;return r?n.createElement(f,i(i({ref:t},c),{},{components:r})):n.createElement(f,i({ref:t},c))}));function f(e,t){var r=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var o=r.length,i=new Array(o);i[0]=d;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l[p]="string"==typeof e?e:a,i[1]=l;for(var u=2;u<o;u++)i[u]=r[u];return n.createElement.apply(null,i)}return n.createElement.apply(null,r)}d.displayName="MDXCreateElement"},4747:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>s,contentTitle:()=>i,default:()=>p,frontMatter:()=>o,metadata:()=>l,toc:()=>u});var n=r(7462),a=(r(7294),r(3905));const o={},i="Courier Flutter - Contribution Guidelines",l={unversionedId:"CONTRIBUTION",id:"CONTRIBUTION",title:"Courier Flutter - Contribution Guidelines",description:"Courier Flutter is an open-source project.",source:"@site/docs/CONTRIBUTION.md",sourceDirName:".",slug:"/CONTRIBUTION",permalink:"/courier-flutter/docs/CONTRIBUTION",draft:!1,editUrl:"https://github.com/gojek/courier-flutter/edit/main/docs/docs/CONTRIBUTION.md",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"Event Handling",permalink:"/courier-flutter/docs/Event Handling"},next:{title:"LICENSE",permalink:"/courier-flutter/docs/LICENSE"}},s={},u=[{value:"Issue Reporting",id:"issue-reporting",level:2},{value:"Pull Requests",id:"pull-requests",level:2}],c={toc:u};function p(e){let{components:t,...r}=e;return(0,a.kt)("wrapper",(0,n.Z)({},c,r,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"courier-flutter---contribution-guidelines"},"Courier Flutter - Contribution Guidelines"),(0,a.kt)("p",null,(0,a.kt)("a",{parentName:"p",href:"https://github.com/gojek/courier-flutter"},"Courier Flutter")," is an open-source project.\nIt is licensed using the ",(0,a.kt)("a",{parentName:"p",href:"https://opensource.org/licenses/MIT"},"MIT License"),".\nWe appreciate pull requests; here are our guidelines:"),(0,a.kt)("ol",null,(0,a.kt)("li",{parentName:"ol"},(0,a.kt)("p",{parentName:"li"},(0,a.kt)("a",{parentName:"p",href:"https://github.com/gojek/courier-flutter/issues"},"File an issue"),"\n(if there isn't one already). If your patch\nis going to be large it might be a good idea to get the\ndiscussion started early.  We are happy to discuss it in a\nnew issue beforehand, and you can always email\n",(0,a.kt)("a",{parentName:"p",href:"mailto:foss+tech@go-jek.com"},"foss+tech@go-jek.com")," about future work.")),(0,a.kt)("li",{parentName:"ol"},(0,a.kt)("p",{parentName:"li"},"Please follow ",(0,a.kt)("a",{parentName:"p",href:"https://google.github.io/swift/"},"Swift Coding Conventions"),".")),(0,a.kt)("li",{parentName:"ol"},(0,a.kt)("p",{parentName:"li"},"We ask that you squash all the commits together before\npushing and that your commit message references the bug."))),(0,a.kt)("h2",{id:"issue-reporting"},"Issue Reporting"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Check that the issue has not already been reported."),(0,a.kt)("li",{parentName:"ul"},"Be clear, concise and precise in your description of the problem."),(0,a.kt)("li",{parentName:"ul"},"Open an issue with a descriptive title and a summary in grammatically correct,\ncomplete sentences."),(0,a.kt)("li",{parentName:"ul"},"Include any relevant code to the issue summary.")),(0,a.kt)("h2",{id:"pull-requests"},"Pull Requests"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"Please read this ",(0,a.kt)("a",{parentName:"li",href:"http://gun.io/blog/how-to-github-fork-branch-and-pull-request"},"how to GitHub")," blog post."),(0,a.kt)("li",{parentName:"ul"},"Use a topic branch to easily amend a pull request later, if necessary."),(0,a.kt)("li",{parentName:"ul"},"Write ",(0,a.kt)("a",{parentName:"li",href:"http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html"},"good commit messages"),"."),(0,a.kt)("li",{parentName:"ul"},"Use the same coding conventions as the rest of the project."),(0,a.kt)("li",{parentName:"ul"},"Open a ",(0,a.kt)("a",{parentName:"li",href:"https://help.github.com/articles/using-pull-requests"},"pull request")," that relates to ",(0,a.kt)("em",{parentName:"li"},"only")," one subject with a clear title\nand description in grammatically correct, complete sentences.")),(0,a.kt)("p",null,"Much Thanks! \u2764\u2764\u2764"),(0,a.kt)("p",null,"GO-JEK Tech"))}p.isMDXComponent=!0}}]);