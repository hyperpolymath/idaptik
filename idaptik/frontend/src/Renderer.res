// Canvas 2D renderer for the game

type context2d
type canvas

@send external getContext: (canvas, @as("2d") _) => option<context2d> = "getContext"

// Canvas operations
@set external setFillStyle: (context2d, string) => unit = "fillStyle"
@set external setStrokeStyle: (context2d, string) => unit = "strokeStyle"
@set external setLineWidth: (context2d, float) => unit = "lineWidth"
@set external setGlobalAlpha: (context2d, float) => unit = "globalAlpha"

@send external fillRect: (context2d, ~x: float, ~y: float, ~width: float, ~height: float) => unit = "fillRect"
@send external strokeRect: (context2d, ~x: float, ~y: float, ~width: float, ~height: float) => unit = "strokeRect"
@send external clearRect: (context2d, ~x: float, ~y: float, ~width: float, ~height: float) => unit = "clearRect"

@send external beginPath: context2d => unit = "beginPath"
@send external closePath: context2d => unit = "closePath"
@send external arc: (context2d, ~x: float, ~y: float, ~radius: float, ~startAngle: float, ~endAngle: float) => unit = "arc"
@send external fill: context2d => unit = "fill"
@send external stroke: context2d => unit = "stroke"

@send external save: context2d => unit = "save"
@send external restore: context2d => unit = "restore"
@send external translate: (context2d, ~x: float, ~y: float) => unit = "translate"
@send external rotate: (context2d, ~angle: float) => unit = "rotate"

@send external fillText: (context2d, ~text: string, ~x: float, ~y: float) => unit = "fillText"
@set external setFont: (context2d, string) => unit = "font"

type t = {
  canvas: canvas,
  ctx: context2d,
  width: float,
  height: float,
}

let create = (canvas: canvas): option<t> => {
  switch canvas->getContext {
  | Some(ctx) => {
      // Get canvas dimensions
      let width = Float.fromInt(canvas["width"])
      let height = Float.fromInt(canvas["height"])
      
      Some({canvas, ctx, width, height})
    }
  | None => None
  }
}

let clear = (renderer: t): unit => {
  renderer.ctx->clearRect(~x=0.0, ~y=0.0, ~width=renderer.width, ~height=renderer.height)
}

// Render the game world
let render = (renderer: t, ~state: WasmEngine.gameState): unit => {
  clear(renderer)
  
  // Draw background
  renderer.ctx->setFillStyle("#1a1a2e")
  renderer.ctx->fillRect(~x=0.0, ~y=0.0, ~width=renderer.width, ~height=renderer.height)
  
  // Draw lights (glow effect)
  Array.forEach(state.lights, light => {
    let gradient = renderer.ctx["createRadialGradient"](
      light.position.x,
      light.position.y,
      0.0,
      light.position.x,
      light.position.y,
      light.radius,
    )
    gradient["addColorStop"](0.0, `rgba(255, 255, 200, ${Float.toString(light.intensity * 0.3)})`)
    gradient["addColorStop"](1.0, "rgba(255, 255, 200, 0)")
    
    renderer.ctx->setFillStyle(gradient)
    renderer.ctx->beginPath()
    renderer.ctx->arc(
      ~x=light.position.x,
      ~y=light.position.y,
      ~radius=light.radius,
      ~startAngle=0.0,
      ~endAngle=Float.Constants.pi *. 2.0,
    )
    renderer.ctx->fill()
  })
  
  // Draw obstacles
  Array.forEach(state.obstacles, obstacle => {
    renderer.ctx->setFillStyle("#3d3d5c")
    renderer.ctx->setStrokeStyle("#5d5d7c")
    renderer.ctx->setLineWidth(2.0)
    
    renderer.ctx->beginPath()
    renderer.ctx->arc(
      ~x=obstacle.position.x,
      ~y=obstacle.position.y,
      ~radius=obstacle.radius,
      ~startAngle=0.0,
      ~endAngle=Float.Constants.pi *. 2.0,
    )
    renderer.ctx->fill()
    renderer.ctx->stroke()
  })
  
  // Draw entities
  Array.forEach(state.entities, entity => {
    renderer.ctx->save()
    
    // Translate to entity position
    renderer.ctx->translate(~x=entity.position.x, ~y=entity.position.y)
    renderer.ctx->rotate(~angle=entity.rotation)
    
    // Choose color based on type
    let (bodyColor, outlineColor) = switch entity.entity_type {
    | "Player" => ("#4ecdc4", "#2a9d8f")
    | "Guard" => ("#ff6b6b", "#c92a2a")
    | _ => ("#888888", "#666666")
    }
    
    // Draw body
    renderer.ctx->setFillStyle(bodyColor)
    renderer.ctx->setStrokeStyle(outlineColor)
    renderer.ctx->setLineWidth(2.0)
    
    renderer.ctx->beginPath()
    renderer.ctx->arc(~x=0.0, ~y=0.0, ~radius=8.0, ~startAngle=0.0, ~endAngle=Float.Constants.pi *. 2.0)
    renderer.ctx->fill()
    renderer.ctx->stroke()
    
    // Draw direction indicator
    renderer.ctx->setStrokeStyle(outlineColor)
    renderer.ctx->setLineWidth(3.0)
    renderer.ctx->beginPath()
    renderer.ctx["moveTo"](0.0, 0.0)
    renderer.ctx["lineTo"](12.0, 0.0)
    renderer.ctx->stroke()
    
    // Draw vision cone for guards
    if entity.entity_type == "Guard" {
      renderer.ctx->setFillStyle("rgba(255, 107, 107, 0.1)")
      renderer.ctx->setStrokeStyle("rgba(255, 107, 107, 0.3)")
      renderer.ctx->setLineWidth(1.0)
      
      renderer.ctx->beginPath()
      renderer.ctx["moveTo"](0.0, 0.0)
      renderer.ctx->arc(
        ~x=0.0,
        ~y=0.0,
        ~radius=entity.visibility_radius,
        ~startAngle=-.entity.field_of_view /. 2.0,
        ~endAngle=entity.field_of_view /. 2.0,
      )
      renderer.ctx["lineTo"](0.0, 0.0)
      renderer.ctx->fill()
      renderer.ctx->stroke()
    }
    
    // Draw detection meter for players
    if entity.entity_type == "Player" && entity.detection_level > 0.01 {
      renderer.ctx->setFillStyle(
        if entity.detection_level > 0.7 {
          "#ff4444"
        } else if entity.detection_level > 0.4 {
          "#ffaa44"
        } else {
          "#ffff44"
        },
      )
      renderer.ctx->fillRect(
        ~x=-10.0,
        ~y=-15.0,
        ~width=20.0 *. entity.detection_level,
        ~height=3.0,
      )
    }
    
    renderer.ctx->restore()
  })
  
  // Draw UI overlay
  renderer.ctx->setFont("14px monospace")
  renderer.ctx->setFillStyle("#ffffff")
  
  let playerCount = Array.reduce(state.entities, 0, (count, entity) => {
    entity.entity_type == "Player" ? count + 1 : count
  })
  
  let guardCount = Array.reduce(state.entities, 0, (count, entity) => {
    entity.entity_type == "Guard" ? count + 1 : count
  })
  
  renderer.ctx->fillText(~text=`Players: ${Int.toString(playerCount)}`, ~x=10.0, ~y=20.0)
  renderer.ctx->fillText(~text=`Guards: ${Int.toString(guardCount)}`, ~x=10.0, ~y=40.0)
  renderer.ctx->fillText(
    ~text=`Ambient Light: ${Float.toString(state.ambient_light *. 100.0)}%`,
    ~x=10.0,
    ~y=60.0,
  )
}
