(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[85],{3905:function(e,t,n){"use strict";n.d(t,{Zo:function(){return u},kt:function(){return d}});var r=n(67294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function l(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?l(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):l(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function i(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},l=Object.keys(e);for(r=0;r<l.length;r++)n=l[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var l=Object.getOwnPropertySymbols(e);for(r=0;r<l.length;r++)n=l[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var c=r.createContext({}),s=function(e){var t=r.useContext(c),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},u=function(e){var t=s(e.components);return r.createElement(c.Provider,{value:t},e.children)},p={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},m=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,l=e.originalType,c=e.parentName,u=i(e,["components","mdxType","originalType","parentName"]),m=s(n),d=a,y=m["".concat(c,".").concat(d)]||m[d]||p[d]||l;return n?r.createElement(y,o(o({ref:t},u),{},{components:n})):r.createElement(y,o({ref:t},u))}));function d(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var l=n.length,o=new Array(l);o[0]=m;var i={};for(var c in t)hasOwnProperty.call(t,c)&&(i[c]=t[c]);i.originalType=e,i.mdxType="string"==typeof e?e:a,o[1]=i;for(var s=2;s<l;s++)o[s]=n[s];return r.createElement.apply(null,o)}return r.createElement.apply(null,n)}m.displayName="MDXCreateElement"},39649:function(e,t,n){"use strict";n.d(t,{Z:function(){return d}});var r=n(63366),a=n(87462),l=n(67294),o=n(86010),i=n(95999),c=n(32822),s="anchorWithStickyNavbar_31ik",u="anchorWithHideOnScrollNavbar_3R7-",p=["id"],m=function(e){var t=Object.assign({},e);return l.createElement("header",null,l.createElement("h1",(0,a.Z)({},t,{id:void 0}),t.children))},d=function(e){return"h1"===e?m:(t=e,function(e){var n,m=e.id,d=(0,r.Z)(e,p),y=(0,c.LU)().navbar.hideOnScroll;return m?l.createElement(t,(0,a.Z)({},d,{className:(0,o.Z)("anchor",(n={},n[u]=y,n[s]=!y,n)),id:m}),d.children,l.createElement("a",{"aria-hidden":"true",className:"hash-link",href:"#"+m,title:(0,i.I)({id:"theme.common.headingLinkTitle",message:"Direct link to heading",description:"Title for link to heading"})},"\u200b")):l.createElement(t,d)});var t}},4083:function(e,t,n){"use strict";n.r(t),n.d(t,{default:function(){return G}});var r=n(67294),a=n(86010),l=n(97890),o=n(3905),i=n(87462),c=n(63366),s=n(12859),u=n(39960),p={plain:{backgroundColor:"#2a2734",color:"#9a86fd"},styles:[{types:["comment","prolog","doctype","cdata","punctuation"],style:{color:"#6c6783"}},{types:["namespace"],style:{opacity:.7}},{types:["tag","operator","number"],style:{color:"#e09142"}},{types:["property","function"],style:{color:"#9a86fd"}},{types:["tag-id","selector","atrule-id"],style:{color:"#eeebff"}},{types:["attr-name"],style:{color:"#c4b9fe"}},{types:["boolean","string","entity","url","attr-value","keyword","control","directive","unit","statement","regex","at-rule","placeholder","variable"],style:{color:"#ffcc99"}},{types:["deleted"],style:{textDecorationLine:"line-through"}},{types:["inserted"],style:{textDecorationLine:"underline"}},{types:["italic"],style:{fontStyle:"italic"}},{types:["important","bold"],style:{fontWeight:"bold"}},{types:["important"],style:{color:"#c4b9fe"}}]},m={Prism:n(87410).default,theme:p};function d(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function y(){return y=Object.assign||function(e){for(var t=1;t<arguments.length;t++){var n=arguments[t];for(var r in n)Object.prototype.hasOwnProperty.call(n,r)&&(e[r]=n[r])}return e},y.apply(this,arguments)}var f=/\r\n|\r|\n/,h=function(e){0===e.length?e.push({types:["plain"],content:"\n",empty:!0}):1===e.length&&""===e[0].content&&(e[0].content="\n",e[0].empty=!0)},g=function(e,t){var n=e.length;return n>0&&e[n-1]===t?e:e.concat(t)},v=function(e,t){var n=e.plain,r=Object.create(null),a=e.styles.reduce((function(e,n){var r=n.languages,a=n.style;return r&&!r.includes(t)||n.types.forEach((function(t){var n=y({},e[t],a);e[t]=n})),e}),r);return a.root=n,a.plain=y({},n,{backgroundColor:null}),a};function b(e,t){var n={};for(var r in e)Object.prototype.hasOwnProperty.call(e,r)&&-1===t.indexOf(r)&&(n[r]=e[r]);return n}var k=function(e){function t(){for(var t=this,n=[],r=arguments.length;r--;)n[r]=arguments[r];e.apply(this,n),d(this,"getThemeDict",(function(e){if(void 0!==t.themeDict&&e.theme===t.prevTheme&&e.language===t.prevLanguage)return t.themeDict;t.prevTheme=e.theme,t.prevLanguage=e.language;var n=e.theme?v(e.theme,e.language):void 0;return t.themeDict=n})),d(this,"getLineProps",(function(e){var n=e.key,r=e.className,a=e.style,l=y({},b(e,["key","className","style","line"]),{className:"token-line",style:void 0,key:void 0}),o=t.getThemeDict(t.props);return void 0!==o&&(l.style=o.plain),void 0!==a&&(l.style=void 0!==l.style?y({},l.style,a):a),void 0!==n&&(l.key=n),r&&(l.className+=" "+r),l})),d(this,"getStyleForToken",(function(e){var n=e.types,r=e.empty,a=n.length,l=t.getThemeDict(t.props);if(void 0!==l){if(1===a&&"plain"===n[0])return r?{display:"inline-block"}:void 0;if(1===a&&!r)return l[n[0]];var o=r?{display:"inline-block"}:{},i=n.map((function(e){return l[e]}));return Object.assign.apply(Object,[o].concat(i))}})),d(this,"getTokenProps",(function(e){var n=e.key,r=e.className,a=e.style,l=e.token,o=y({},b(e,["key","className","style","token"]),{className:"token "+l.types.join(" "),children:l.content,style:t.getStyleForToken(l),key:void 0});return void 0!==a&&(o.style=void 0!==o.style?y({},o.style,a):a),void 0!==n&&(o.key=n),r&&(o.className+=" "+r),o})),d(this,"tokenize",(function(e,t,n,r){var a={code:t,grammar:n,language:r,tokens:[]};e.hooks.run("before-tokenize",a);var l=a.tokens=e.tokenize(a.code,a.grammar,a.language);return e.hooks.run("after-tokenize",a),l}))}return e&&(t.__proto__=e),t.prototype=Object.create(e&&e.prototype),t.prototype.constructor=t,t.prototype.render=function(){var e=this.props,t=e.Prism,n=e.language,r=e.code,a=e.children,l=this.getThemeDict(this.props),o=t.languages[n];return a({tokens:function(e){for(var t=[[]],n=[e],r=[0],a=[e.length],l=0,o=0,i=[],c=[i];o>-1;){for(;(l=r[o]++)<a[o];){var s=void 0,u=t[o],p=n[o][l];if("string"==typeof p?(u=o>0?u:["plain"],s=p):(u=g(u,p.type),p.alias&&(u=g(u,p.alias)),s=p.content),"string"==typeof s){var m=s.split(f),d=m.length;i.push({types:u,content:m[0]});for(var y=1;y<d;y++)h(i),c.push(i=[]),i.push({types:u,content:m[y]})}else o++,t.push(u),n.push(s),r.push(0),a.push(s.length)}o--,t.pop(),n.pop(),r.pop(),a.pop()}return h(i),c}(void 0!==o?this.tokenize(t,r,o,n):[r]),className:"prism-code language-"+n,style:void 0!==l?l.root:{},getLineProps:this.getLineProps,getTokenProps:this.getTokenProps})},t}(r.Component),E=k;var N=n(87594),j=n.n(N),O={plain:{color:"#bfc7d5",backgroundColor:"#292d3e"},styles:[{types:["comment"],style:{color:"rgb(105, 112, 152)",fontStyle:"italic"}},{types:["string","inserted"],style:{color:"rgb(195, 232, 141)"}},{types:["number"],style:{color:"rgb(247, 140, 108)"}},{types:["builtin","char","constant","function"],style:{color:"rgb(130, 170, 255)"}},{types:["punctuation","selector"],style:{color:"rgb(199, 146, 234)"}},{types:["variable"],style:{color:"rgb(191, 199, 213)"}},{types:["class-name","attr-name"],style:{color:"rgb(255, 203, 107)"}},{types:["tag","deleted"],style:{color:"rgb(255, 85, 114)"}},{types:["operator"],style:{color:"rgb(137, 221, 255)"}},{types:["boolean"],style:{color:"rgb(255, 88, 116)"}},{types:["keyword"],style:{fontStyle:"italic"}},{types:["doctype"],style:{color:"rgb(199, 146, 234)",fontStyle:"italic"}},{types:["namespace"],style:{color:"rgb(178, 204, 214)"}},{types:["url"],style:{color:"rgb(221, 221, 221)"}}]},C=n(85350),x=n(32822),Z=function(){var e=(0,x.LU)().prism,t=(0,C.Z)().isDarkTheme,n=e.theme||O,r=e.darkTheme||n;return t?r:n},T=n(95999),_="codeBlockContainer_K1bP",P="codeBlockContent_hGly",L="codeBlockTitle_eoMF",w="codeBlock_23N8",S="copyButton_Ue-o",D="codeBlockLines_39YC",A=/{([\d,-]+)}/,B=["js","jsBlock","jsx","python","html"],H={js:{start:"\\/\\/",end:""},jsBlock:{start:"\\/\\*",end:"\\*\\/"},jsx:{start:"\\{\\s*\\/\\*",end:"\\*\\/\\s*\\}"},python:{start:"#",end:""},html:{start:"\x3c!--",end:"--\x3e"}},I=["highlight-next-line","highlight-start","highlight-end"],R=function(e){void 0===e&&(e=B);var t=e.map((function(e){var t=H[e],n=t.start,r=t.end;return"(?:"+n+"\\s*("+I.join("|")+")\\s*"+r+")"})).join("|");return new RegExp("^\\s*(?:"+t+")\\s*$")};function M(e){var t=e.children,n=e.className,l=e.metastring,o=e.title,c=(0,x.LU)().prism,s=(0,r.useState)(!1),u=s[0],p=s[1],d=(0,r.useState)(!1),y=d[0],f=d[1];(0,r.useEffect)((function(){f(!0)}),[]);var h=(0,x.bc)(l)||o,g=(0,r.useRef)(null),v=[],b=Z(),k=Array.isArray(t)?t.join(""):t;if(l&&A.test(l)){var N=l.match(A)[1];v=j()(N).filter((function(e){return e>0}))}var O=null==n?void 0:n.split(" ").find((function(e){return e.startsWith("language-")})),C=null==O?void 0:O.replace(/language-/,"");!C&&c.defaultLanguage&&(C=c.defaultLanguage);var B=k.replace(/\n$/,"");if(0===v.length&&void 0!==C){for(var H,I="",M=function(e){switch(e){case"js":case"javascript":case"ts":case"typescript":return R(["js","jsBlock"]);case"jsx":case"tsx":return R(["js","jsBlock","jsx"]);case"html":return R(["js","jsBlock","html"]);case"python":case"py":return R(["python"]);default:return R()}}(C),z=k.replace(/\n$/,"").split("\n"),F=0;F<z.length;){var U=F+1,V=z[F].match(M);if(null!==V){switch(V.slice(1).reduce((function(e,t){return e||t}),void 0)){case"highlight-next-line":I+=U+",";break;case"highlight-start":H=U;break;case"highlight-end":I+=H+"-"+(U-1)+","}z.splice(F,1)}else F+=1}v=j()(I),B=z.join("\n")}var W=function(){!function(e,{target:t=document.body}={}){const n=document.createElement("textarea"),r=document.activeElement;n.value=e,n.setAttribute("readonly",""),n.style.contain="strict",n.style.position="absolute",n.style.left="-9999px",n.style.fontSize="12pt";const a=document.getSelection();let l=!1;a.rangeCount>0&&(l=a.getRangeAt(0)),t.append(n),n.select(),n.selectionStart=0,n.selectionEnd=e.length;let o=!1;try{o=document.execCommand("copy")}catch{}n.remove(),l&&(a.removeAllRanges(),a.addRange(l)),r&&r.focus()}(B),p(!0),setTimeout((function(){return p(!1)}),2e3)};return r.createElement(E,(0,i.Z)({},m,{key:String(y),theme:b,code:B,language:C}),(function(e){var t=e.className,l=e.style,o=e.tokens,c=e.getLineProps,s=e.getTokenProps;return r.createElement("div",{className:(0,a.Z)(_,null==n?void 0:n.replace(/language-[^ ]+/,""))},h&&r.createElement("div",{style:l,className:L},h),r.createElement("div",{className:(0,a.Z)(P,C)},r.createElement("pre",{tabIndex:0,className:(0,a.Z)(t,w,"thin-scrollbar"),style:l},r.createElement("code",{className:D},o.map((function(e,t){1===e.length&&"\n"===e[0].content&&(e[0].content="");var n=c({line:e,key:t});return v.includes(t+1)&&(n.className+=" docusaurus-highlight-code-line"),r.createElement("span",(0,i.Z)({key:t},n),e.map((function(e,t){return r.createElement("span",(0,i.Z)({key:t},s({token:e,key:t})))})),r.createElement("br",null))})))),r.createElement("button",{ref:g,type:"button","aria-label":(0,T.I)({id:"theme.CodeBlock.copyButtonAriaLabel",message:"Copy code to clipboard",description:"The ARIA label for copy code blocks button"}),className:(0,a.Z)(S,"clean-btn"),onClick:W},u?r.createElement(T.Z,{id:"theme.CodeBlock.copied",description:"The copied button label on code blocks"},"Copied"):r.createElement(T.Z,{id:"theme.CodeBlock.copy",description:"The copy button label on code blocks"},"Copy"))))}))}var z=n(39649),F="details_1VDD";function U(e){var t=Object.assign({},e);return r.createElement(x.PO,(0,i.Z)({},t,{className:(0,a.Z)("alert alert--info",F,t.className)}))}var V=["mdxType","originalType"];var W={head:function(e){var t=r.Children.map(e.children,(function(e){return function(e){var t,n;if(null!=e&&null!=(t=e.props)&&t.mdxType&&null!=e&&null!=(n=e.props)&&n.originalType){var a=e.props,l=(a.mdxType,a.originalType,(0,c.Z)(a,V));return r.createElement(e.props.originalType,l)}return e}(e)}));return r.createElement(s.Z,e,t)},code:function(e){var t=e.children;return(0,r.isValidElement)(t)?t:t.includes("\n")?r.createElement(M,e):r.createElement("code",e)},a:function(e){return r.createElement(u.Z,e)},pre:function(e){var t,n=e.children;return(0,r.isValidElement)(n)&&(0,r.isValidElement)(null==n||null==(t=n.props)?void 0:t.children)?n.props.children:r.createElement(M,(0,r.isValidElement)(n)?null==n?void 0:n.props:Object.assign({},e))},details:function(e){var t=r.Children.toArray(e.children),n=t.find((function(e){var t;return"summary"===(null==e||null==(t=e.props)?void 0:t.mdxType)})),a=r.createElement(r.Fragment,null,t.filter((function(e){return e!==n})));return r.createElement(U,(0,i.Z)({},e,{summary:n}),a)},h1:(0,z.Z)("h1"),h2:(0,z.Z)("h2"),h3:(0,z.Z)("h3"),h4:(0,z.Z)("h4"),h5:(0,z.Z)("h5"),h6:(0,z.Z)("h6")},$=n(51575),q="mdxPageWrapper_3qD3";var G=function(e){var t=e.content,n=t.frontMatter,i=t.metadata,c=n.title,s=n.description,u=n.wrapperClassName,p=n.hide_table_of_contents,m=i.permalink;return r.createElement(l.Z,{title:c,description:s,permalink:m,wrapperClassName:null!=u?u:x.kM.wrapper.mdxPages,pageClassName:x.kM.page.mdxPage},r.createElement("main",{className:"container container--fluid margin-vert--lg"},r.createElement("div",{className:(0,a.Z)("row",q)},r.createElement("div",{className:(0,a.Z)("col",!p&&"col--8")},r.createElement(o.Zo,{components:W},r.createElement(t,null))),!p&&t.toc&&r.createElement("div",{className:"col col--2"},r.createElement($.Z,{toc:t.toc,minHeadingLevel:n.toc_min_heading_level,maxHeadingLevel:n.toc_max_heading_level})))))}},25002:function(e,t,n){"use strict";n.d(t,{Z:function(){return s}});var r=n(87462),a=n(63366),l=n(67294),o=n(32822),i=["toc","className","linkClassName","linkActiveClassName","minHeadingLevel","maxHeadingLevel"];function c(e){var t=e.toc,n=e.className,r=e.linkClassName,a=e.isChild;return t.length?l.createElement("ul",{className:a?void 0:n},t.map((function(e){return l.createElement("li",{key:e.id},l.createElement("a",{href:"#"+e.id,className:null!=r?r:void 0,dangerouslySetInnerHTML:{__html:e.value}}),l.createElement(c,{isChild:!0,toc:e.children,className:n,linkClassName:r}))}))):null}function s(e){var t=e.toc,n=e.className,s=void 0===n?"table-of-contents table-of-contents__left-border":n,u=e.linkClassName,p=void 0===u?"table-of-contents__link":u,m=e.linkActiveClassName,d=void 0===m?void 0:m,y=e.minHeadingLevel,f=e.maxHeadingLevel,h=(0,a.Z)(e,i),g=(0,o.LU)(),v=null!=y?y:g.tableOfContents.minHeadingLevel,b=null!=f?f:g.tableOfContents.maxHeadingLevel,k=(0,o.DA)({toc:t,minHeadingLevel:v,maxHeadingLevel:b}),E=(0,l.useMemo)((function(){if(p&&d)return{linkClassName:p,linkActiveClassName:d,minHeadingLevel:v,maxHeadingLevel:b}}),[p,d,v,b]);return(0,o.Si)(E),l.createElement(c,(0,r.Z)({toc:k,className:s,linkClassName:p},h))}},51575:function(e,t,n){"use strict";n.d(t,{Z:function(){return u}});var r=n(87462),a=n(63366),l=n(67294),o=n(86010),i=n(25002),c="tableOfContents_35-E",s=["className"];var u=function(e){var t=e.className,n=(0,a.Z)(e,s);return l.createElement("div",{className:(0,o.Z)(c,"thin-scrollbar",t)},l.createElement(i.Z,(0,r.Z)({},n,{linkClassName:"table-of-contents__link toc-highlight",linkActiveClassName:"table-of-contents__link--active"})))}},87594:function(e,t){function n(e){let t,n=[];for(let r of e.split(",").map((e=>e.trim())))if(/^-?\d+$/.test(r))n.push(parseInt(r,10));else if(t=r.match(/^(-?\d+)(-|\.\.\.?|\u2025|\u2026|\u22EF)(-?\d+)$/)){let[e,r,a,l]=t;if(r&&l){r=parseInt(r),l=parseInt(l);const e=r<l?1:-1;"-"!==a&&".."!==a&&"\u2025"!==a||(l+=e);for(let t=r;t!==l;t+=e)n.push(t)}}return n}t.default=n,e.exports=n}}]);