use "collections"
use "math"
use "time"

actor Node
  let id: U64
  var s: F64
  var w: F64
  var neighbors: Array[Node tag] val
  var count: U64
  var ratio: F64
  let algorithm: String
  var active: Bool = true
  let env: Env
  var round_counts: U64
  var stopped: Bool = false
  let main: Main

  new create(id': U64, algorithm': String, env': Env, main': Main) =>
    env = env'
    id = id'
    count = 0
    algorithm = algorithm'
    neighbors = Array[Node tag]
    s = id'.f64()
    w = 1.0 
    ratio = s / w
    round_counts = 0
    main = main'
    env.out.print("Node created with ID: " + id.string())

  be set_neighbors(neighbors': Array[Node tag] val) =>
    neighbors = neighbors'

  be get_neighbors(caller: Main) =>
    caller.receive_neighbors(this, neighbors)

  be start() =>
    match algorithm
    | "gossip" => gossip()
    | "push-sum" => push_sum(0.0, 0.0)
    else
      env.out.print("node " + id.string() + " algorithm is invalid")
    end

  be gossip() =>
    while count < 10 do
      if (stopped == false) then
        count = count + 1
        env.out.print("Node " + id.string() + " gossip count: " + count.string())
        if neighbors.size() > 0 then
          try
            let neighbor = neighbors((Time.nanos() % neighbors.size().u64()).usize())?
            neighbor.gossip()
          else
            env.out.print("node " + id.string() + " error occurred while selecting a neighbor")
          end
        end
      else
        stop_node("gossip")
        break
      end
    end
    stop_node("gossip")

  be push_sum(s': F64, w': F64) =>
    while round_counts < 3 do
      s = s + s'
      w = w + w'
      let new_ratio = s / w
      if (ratio - new_ratio).abs() < 0.0000000001 then
        round_counts = round_counts + 1
      else
        round_counts = 0
      end
      ratio = new_ratio
      try
        let neighbor = neighbors((Time.nanos() % neighbors.size().u64()).usize())?
        neighbor.push_sum(s / 2.0, w / 2.0)
        s = s / 2.0
        w = w / 2.0
      else
        env.out.print("node " + id.string() + " error occurred while selecting a neighbor")
      end
    end
    stop_node("push-sum")

  fun ref stop_node(algo_name: String) =>
    if not stopped then
      stopped = true
      active = false
      env.out.print("节点 " + id.string() + " 已停止 " + algo_name + "，比率为 " + ratio.string())
      main.node_stopped()
    end

actor Main
  var num_nodes: U64 = 0
  var stopped_count: U64 = 0
  let env: Env
  var all_stopped: Bool = false
  var start_time: U64 = 0
  var nodes: Array[Node tag] val = Array[Node tag]

  new create(env': Env) =>
    env = env'
    let args = env.args

    if args.size() < 4 then
      env.out.print("error input")
      return
    end

    try
      num_nodes = args(1)?.u64()?
      let topology = args(2)?
      let algorithm = args(3)?

      if num_nodes <= 0 then
        env.out.print("nums must be a positive integer.")
        return
      end

      if ((algorithm != "gossip") and (algorithm != "push-sum")) then
        env.out.print("error algorithm")
        return
      end

      if (topology != "full") and (topology != "line") and (topology != "3D") and (topology != "imp3D") then
        env.out.print("error topology")
        return
      end

      env.out.print("the number of nodes: " + num_nodes.string())
      env.out.print("topology: " + topology)
      env.out.print("algorithm: " + algorithm)

      nodes = recover val
        let arr = Array[Node tag]
        for i in Range[U64](0, num_nodes) do
          arr.push(Node(i, algorithm, env, this))
        end
        arr
      end

      // 记录开始时间
      start_time = Time.nanos()
      env.out.print("Start time: " + start_time.string())

      match topology
      | "full" => full_topology(nodes)
      | "line" => 
        try
          line_topology(nodes)?
        else
          env.out.print("Error setting up line topology")
        end
      | "3D" => 
        try
          grid_topology(nodes)?
        else
          env.out.print("Error setting up 3D topology")
        end
      | "imp3D" => 
        try 
          imperfect_grid_topology(nodes)?
        else
          env.out.print("Error setting up imperfect 3D topology")
        end
      end

      for node in nodes.values() do
        node.start()
      end
    else
      env.out.print("error")
    end

  fun full_topology(node_list: Array[Node tag] val) =>
    for node in node_list.values() do
      node.set_neighbors(node_list)
    end

  fun line_topology(node_list: Array[Node tag] val) ? =>
    for i in Range[USize](0, node_list.size()) do
      let neighbors = recover val
        let arr = Array[Node tag]
        if i > 0 then
          arr.push(node_list(i-1)?)
        end
        if i < (node_list.size() - 1) then
          arr.push(node_list(i+1)?)
        end
        arr
      end
      node_list(i)?.set_neighbors(neighbors)
    end

  fun grid_topology(node_list: Array[Node tag] val) ? =>
    let side_len: U64 = num_nodes.f64().pow(1.0 / 3.0).ceil().u64()
    for x in Range[U64](0, side_len) do
      for y in Range[U64](0, side_len) do
        for z in Range[U64](0, side_len) do
          let i = ((x * side_len * side_len) + (y * side_len) + z)
          if i < num_nodes then
            let neighbors = recover val
              let arr = Array[Node tag]
              if (x > 0) and ((((x - 1) * side_len * side_len) + (y * side_len) + z) < num_nodes) then
                arr.push(node_list((((x - 1) * side_len * side_len) + (y * side_len) + z).usize())?)
              end
              if (x < (side_len - 1)) and ((((x + 1) * side_len * side_len) + (y * side_len) + z) < num_nodes) then
                arr.push(node_list((((x + 1) * side_len * side_len) + (y * side_len) + z).usize())?)
              end
              if (y > 0) and (((x * side_len * side_len) + ((y - 1) * side_len) + z) < num_nodes) then
                arr.push(node_list(((x * side_len * side_len) + ((y - 1) * side_len) + z).usize())?)
              end
              if (y < (side_len - 1)) and (((x * side_len * side_len) + ((y + 1) * side_len) + z) < num_nodes) then
                arr.push(node_list(((x * side_len * side_len) + ((y + 1) * side_len) + z).usize())?)
              end
              if (z > 0) and (((x * side_len * side_len) + (y * side_len) + (z - 1)) < num_nodes) then
                arr.push(node_list(((x * side_len * side_len) + (y * side_len) + (z - 1)).usize())?)
              end
              if (z < (side_len - 1)) and (((x * side_len * side_len) + (y * side_len) + (z + 1)) < num_nodes )then
                arr.push(node_list(((x * side_len * side_len) + (y * side_len) + (z + 1)).usize())?)
              end
              arr
            end
            node_list(i.usize())?.set_neighbors(neighbors)
          end
        end
      end
    end

  fun imperfect_grid_topology(node_list: Array[Node tag] val) ? =>
    grid_topology(node_list)?
    for node in node_list.values() do
      node.get_neighbors(this)
    end

  be receive_neighbors(node: Node tag, neighbors: Array[Node tag] val) =>
    try
      let random_neighbor = nodes((Time.nanos() % num_nodes).usize())?
      let new_neighbors = recover val
        let arr = Array[Node tag]
        for n in neighbors.values() do
          arr.push(n)
        end
        arr.push(random_neighbor)
        arr
      end
      node.set_neighbors(new_neighbors)
    else
      env.out.print("Error while selecting random neighbor for imperfect grid topology")
    end

  be node_stopped() =>
    stopped_count = stopped_count + 1
    env.out.print("Current stopped count: " + stopped_count.string())
    if (stopped_count == num_nodes) then
      all_stopped = true
      let end_time = Time.nanos()
      env.out.print("End time: " + end_time.string())
      let total_time = (end_time - start_time).f64() / 1000000.0
      env.out.print("程序停止传播。总时间: " + total_time.string() + " ms")
      env.out.print("所有节点已停止。")
  end
