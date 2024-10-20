import matplotlib.pyplot as plt
import numpy as np

# 假设的网络大小和收敛时间数据 (根据实际数据进行修改)
network_sizes = np.array([50, 100, 500, 1000, 2000,3000])  # 网络节点数量

# 收敛时间数据 (假设值，需根据实验结果更新)
gossip_full = np.array([0.4, 0.847, 3.15, 27.996, 80.461,200.512])
gossip_line = np.array([2.817, 7.0783, 44.247, 84.2341,352.088,654.23])
gossip_3d = np.array([0.4952, 1.4482, 10.42287, 39.1406,127.97,244.975])
gossip_imp3d = np.array([0.3861, 1.25, 5.982, 30.5523,90.8188,215.43])

pushsum_full = np.array([0.677, 0.8619, 21.0938, 16.7194, 46.3,78.56])
pushsum_line = np.array([0.9075, 4.154, 27.2237, 148.35, 240.63,785.8902])
pushsum_3d = np.array([0.442, 0.879, 14.908, 28.524, 51.8533,104.8764])
pushsum_imp3d = np.array([0.5755, 1.056, 6.21, 18.91, 45.7124,94.68])

# 创建 Gossip 算法的图表
plt.figure(figsize=(10, 6))
plt.plot(network_sizes, gossip_full, label='Full Topology', marker='o')
plt.plot(network_sizes, gossip_line, label='Line Topology', marker='s')
plt.plot(network_sizes, gossip_3d, label='3D Topology', marker='^')
plt.plot(network_sizes, gossip_imp3d, label='Imperfect 3D Topology', marker='d')
plt.title('Gossip algorithm')
plt.xlabel('number of nodes')
plt.ylabel(' convergence time (ms)')
plt.legend()
plt.grid(True)
plt.show()

# 创建 Push-Sum 算法的图表
"""plt.figure(figsize=(10, 6))
plt.plot(network_sizes, pushsum_full, label='Full Topology', marker='o')
plt.plot(network_sizes, pushsum_line, label='Line Topology', marker='s')
plt.plot(network_sizes, pushsum_3d, label='3D Topology', marker='^')
plt.plot(network_sizes, pushsum_imp3d, label='Imperfect 3D Topology', marker='d')
plt.title('Push-sum algorithm')
plt.xlabel('number of nodes')
plt.ylabel(' convergence time (ms)')
plt.legend()
plt.grid(True)
plt.show()"""
