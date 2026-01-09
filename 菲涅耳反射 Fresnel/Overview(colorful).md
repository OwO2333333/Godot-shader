https://godotshaders.com/snippet/fresnel/

Perhaps one of the more versatile effects for spatial shaders, fresnel is used for many things. From making water look more natural to simulating rim lighting and even creating force fields.
或许是空间着色器中最为多样化的效果之一，菲涅尔被广泛用于多种用途。从让水看起来更自然，到模拟边缘光照，甚至制造力场。

The fresnel effect is simulating the relationship between a surface’s angle and how much light you will see coming from that surface. The more the surface is pointing away from you the more light you’ll see, creating bright edges.
菲涅耳效应模拟了表面角度与你从该表面看到的光量之间的关系。表面越是朝远，你看到的光越多，边缘会很亮。

This snippet lets you colorize the fresnel by multiplying it with an RGB-value and set the intensity to either tone down the effect or, if you crank it up, make it glow. You need to enable Glow in the Environment node. (The clamp() has been removed allowing the fresnel to go beyond 1.0). You can also make the fresnel glow by assigning it to EMISSION.

这个片段允许你通过将菲涅尔与 RGB 值乘以来给菲涅尔上色，并将强度设置为降低效果，或者如果你调大音量，则让它发光。你需要启用环境发光节点。（夹具（） 已被移除，使菲涅尔的温度超过 1.0。）你也可以把菲涅尔分配到发射状态，让它发光。
