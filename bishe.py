import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from sklearn.cluster import KMeans
import random
from collections import deque
import matplotlib
import platform

# ================== 解决中文显示问题 ==================
# 方案1: 设置matplotlib使用系统支持的中文字体
def setup_chinese_font():
    """配置matplotlib支持中文显示"""
    system = platform.system()
    
    if system == 'Windows':
        # Windows系统使用微软雅黑
        font_name = 'Microsoft YaHei'
    elif system == 'Darwin':  # macOS
        font_name = 'PingFang SC'  # 或者 'Heiti SC', 'STHeiti'
    else:  # Linux
        font_name = 'WenQuanYi Zen Hei'  # 文泉驿正黑
    
    try:
        plt.rcParams['font.sans-serif'] = [font_name, 'DejaVu Sans']
        plt.rcParams['axes.unicode_minus'] = False  # 解决负号显示问题
        return True
    except:
        # 如果指定字体不存在，使用默认但忽略警告
        plt.rcParams['font.sans-serif'] = ['SimHei', 'Arial Unicode MS', 'DejaVu Sans']
        plt.rcParams['axes.unicode_minus'] = False
        return False

setup_chinese_font()

# ================== 1. 环境与参数定义 ==================
np.random.seed(42)

# 参数配置
NUM_BLOCKS = 45          # 清洁区块数 >=40
NUM_ROBOTS = 10          # 机器人数量 8-12
PEAK_HOURS = [(7,9), (17,19)]  # 交通高峰时段

# 生成模拟区块数据
blocks = []
for i in range(NUM_BLOCKS):
    x = np.random.uniform(0, 100)
    y = np.random.uniform(0, 100)
    area = np.random.uniform(50, 200)
    base_time = area / 10
    blocks.append({
        'id': i,
        'x': x, 'y': y,
        'area': area,
        'clean_time': base_time,
        'cleaned': False,
        'assigned_robot': None
    })

# ================== 2. 区域划分 ==================
def region_partition(blocks, n_robots):
    positions = np.array([[b['x'], b['y']] for b in blocks])
    times = np.array([b['clean_time'] for b in blocks])
    
    kmeans = KMeans(n_clusters=n_robots, random_state=42, n_init=10)
    labels = kmeans.fit_predict(positions)
    
    robot_loads = [np.sum(times[labels == i]) for i in range(n_robots)]
    for _ in range(30):
        max_idx = np.argmax(robot_loads)
        min_idx = np.argmin(robot_loads)
        if robot_loads[max_idx] - robot_loads[min_idx] < np.mean(times):
            break
        max_robot_blocks = np.where(labels == max_idx)[0]
        if len(max_robot_blocks) == 0:
            break
        transfer_block = max_robot_blocks[np.argmax(times[max_robot_blocks])]
        labels[transfer_block] = min_idx
        robot_loads = [np.sum(times[labels == i]) for i in range(n_robots)]
    
    for idx, robot_id in enumerate(labels):
        blocks[idx]['assigned_robot'] = robot_id
    
    return labels, robot_loads

robot_labels, robot_loads = region_partition(blocks, NUM_ROBOTS)
print("区域划分完成")

# ================== 3. 生成清扫路径 ==================
def generate_robot_paths(blocks, num_robots):
    robot_blocks = [[] for _ in range(num_robots)]
    for b in blocks:
        robot_blocks[b['assigned_robot']].append(b)
    
    robot_paths = []
    for rid in range(num_robots):
        if not robot_blocks[rid]:
            robot_paths.append([])
            continue
        unvisited = robot_blocks[rid].copy()
        path = []
        current_pos = (50, 50)
        
        while unvisited:
            distances = [np.hypot(current_pos[0]-b['x'], current_pos[1]-b['y']) for b in unvisited]
            nearest_idx = np.argmin(distances)
            next_block = unvisited.pop(nearest_idx)
            path.append(next_block)
            current_pos = (next_block['x'], next_block['y'])
        
        robot_paths.append(path)
    
    return robot_paths

robot_paths = generate_robot_paths(blocks, NUM_ROBOTS)

# ================== 4. 动态清扫模拟器 ==================
class CleaningSimulator:
    def __init__(self, blocks, robot_paths, speed=20):
        self.blocks = blocks
        self.robot_paths = robot_paths
        self.speed = speed
        self.num_robots = len(robot_paths)
        
        self.robot_positions = [(50, 50) for _ in range(self.num_robots)]
        self.robot_targets = [None for _ in range(self.num_robots)]
        self.robot_path_idx = [0 for _ in range(self.num_robots)]
        self.robot_cleaning = [False for _ in range(self.num_robots)]
        self.robot_clean_timer = [0 for _ in range(self.num_robots)]
        self.robot_completed = [False for _ in range(self.num_robots)]
        
        for rid in range(self.num_robots):
            if self.robot_paths[rid] and len(self.robot_paths[rid]) > 0:
                self.robot_targets[rid] = self.robot_paths[rid][0]
                self.robot_path_idx[rid] = 1
        
        self.time = 0
        self.completed_blocks = []
        
    def update(self, dt=0.1):
        if self.is_complete():
            return
        
        self.time += dt
        
        for rid in range(self.num_robots):
            if self.robot_completed[rid]:
                continue
            
            if self.robot_cleaning[rid]:
                self.robot_clean_timer[rid] -= dt
                if self.robot_clean_timer[rid] <= 0:
                    target_block = self.robot_targets[rid]
                    target_block['cleaned'] = True
                    self.completed_blocks.append(target_block['id'])
                    self.robot_cleaning[rid] = False
                    
                    if self.robot_path_idx[rid] < len(self.robot_paths[rid]):
                        self.robot_targets[rid] = self.robot_paths[rid][self.robot_path_idx[rid]]
                        self.robot_path_idx[rid] += 1
                    else:
                        self.robot_completed[rid] = True
                        self.robot_targets[rid] = None
            else:
                if self.robot_targets[rid] is not None:
                    target = self.robot_targets[rid]
                    target_pos = (target['x'], target['y'])
                    current_pos = self.robot_positions[rid]
                    
                    dx = target_pos[0] - current_pos[0]
                    dy = target_pos[1] - current_pos[1]
                    distance = np.hypot(dx, dy)
                    
                    if distance < self.speed * dt:
                        self.robot_positions[rid] = target_pos
                        self.robot_cleaning[rid] = True
                        self.robot_clean_timer[rid] = target['clean_time']
                    else:
                        direction = np.array([dx, dy]) / distance
                        self.robot_positions[rid] = (
                            current_pos[0] + direction[0] * self.speed * dt,
                            current_pos[1] + direction[1] * self.speed * dt
                        )
    
    def is_complete(self):
        return all(self.robot_completed)
    
    def get_progress(self):
        cleaned_count = sum(1 for b in self.blocks if b['cleaned'])
        return cleaned_count / len(self.blocks)

# ================== 5. 创建动态可视化（英文标签版本，避免中文问题）==================
simulator = CleaningSimulator(blocks, robot_paths, speed=30)

fig, ax = plt.subplots(figsize=(14, 10))
plt.subplots_adjust(right=0.85)

robot_colors = plt.cm.tab20(np.linspace(0, 1, NUM_ROBOTS))

uncleaned_scatter = None
cleaned_scatter = None
robot_scatters = []
robot_trails = []
robot_trail_points = [deque(maxlen=50) for _ in range(NUM_ROBOTS)]

def init():
    global uncleaned_scatter, cleaned_scatter, robot_scatters, robot_trails
    
    ax.clear()
    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.set_title("Smart Sweeping Robot Cooperative Cleaning Simulation", fontsize=16, fontweight='bold')
    ax.set_xlabel("X Coordinate (m)", fontsize=12)
    ax.set_ylabel("Y Coordinate (m)", fontsize=12)
    ax.grid(True, alpha=0.3)
    
    uncleaned = [(b['x'], b['y']) for b in simulator.blocks if not b['cleaned']]
    if uncleaned:
        uncleaned_scatter = ax.scatter(
            [p[0] for p in uncleaned], [p[1] for p in uncleaned],
            c='lightgray', s=100, marker='s', alpha=0.6, label='Pending'
        )
    
    cleaned = [(b['x'], b['y']) for b in simulator.blocks if b['cleaned']]
    if cleaned:
        cleaned_scatter = ax.scatter(
            [p[0] for p in cleaned], [p[1] for p in cleaned],
            c='green', s=100, marker='s', alpha=0.8, label='Cleaned'
        )
    
    robot_scatters = []
    robot_trails = []
    for rid in range(simulator.num_robots):
        scatter = ax.scatter(
            simulator.robot_positions[rid][0], simulator.robot_positions[rid][1],
            c=[robot_colors[rid]], s=200, marker='o', 
            edgecolors='black', linewidth=2, zorder=10
        )
        robot_scatters.append(scatter)
        
        trail, = ax.plot([], [], c=robot_colors[rid], linewidth=2, alpha=0.7)
        robot_trails.append(trail)
    
    ax.legend(loc='upper left', fontsize=10)
    progress_text = ax.text(0.02, 0.98, '', transform=ax.transAxes, 
                            fontsize=12, verticalalignment='top',
                            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    return robot_scatters + robot_trails + [progress_text]

def update(frame):
    global uncleaned_scatter, cleaned_scatter
    
    for _ in range(2):
        simulator.update(dt=0.1)
    
    uncleaned = [(b['x'], b['y']) for b in simulator.blocks if not b['cleaned']]
    cleaned = [(b['x'], b['y']) for b in simulator.blocks if b['cleaned']]
    
    if uncleaned_scatter:
        uncleaned_scatter.remove()
    if cleaned_scatter:
        cleaned_scatter.remove()
    
    uncleaned_scatter = ax.scatter(
        [p[0] for p in uncleaned], [p[1] for p in uncleaned],
        c='lightgray', s=100, marker='s', alpha=0.6, label='Pending'
    )
    cleaned_scatter = ax.scatter(
        [p[0] for p in cleaned], [p[1] for p in cleaned],
        c='green', s=100, marker='s', alpha=0.8, label='Cleaned'
    )
    
    for rid in range(simulator.num_robots):
        robot_scatters[rid].set_offsets([[simulator.robot_positions[rid][0], 
                                          simulator.robot_positions[rid][1]]])
        
        robot_trail_points[rid].append(simulator.robot_positions[rid])
        trail_x = [p[0] for p in robot_trail_points[rid]]
        trail_y = [p[1] for p in robot_trail_points[rid]]
        robot_trails[rid].set_data(trail_x, trail_y)
        
        if simulator.robot_cleaning[rid]:
            robot_scatters[rid].set_sizes([300])
            robot_scatters[rid].set_alpha(0.9)
        else:
            robot_scatters[rid].set_sizes([200])
            robot_scatters[rid].set_alpha(1.0)
    
    for child in ax.texts:
        child.remove()
    
    progress = simulator.get_progress()
    status_text = f"Progress: {progress*100:.1f}%\n"
    status_text += f"Completed: {len(simulator.completed_blocks)}/{len(simulator.blocks)}\n"
    status_text += f"Time: {simulator.time:.1f} sec"
    
    progress_text = ax.text(0.02, 0.98, status_text, transform=ax.transAxes, 
                            fontsize=12, verticalalignment='top',
                            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    if simulator.is_complete():
        ax.text(0.5, 0.5, "CLEANING COMPLETE!", transform=ax.transAxes,
                fontsize=20, fontweight='bold', ha='center', va='center',
                bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.9))
    
    return robot_scatters + robot_trails + [progress_text]

print("Starting dynamic cleaning simulation...")
print("Each robot has different color, Gray=Pending, Green=Cleaned")
print("Robot circle enlarges when cleaning")

anim = FuncAnimation(fig, update, init_func=init, frames=None, 
                     interval=50, blit=False, repeat=False)

plt.tight_layout()
plt.show()

# ================== 6. 最终统计输出 ==================
print("\n" + "="*50)
print("Cleaning Simulation Complete!")
print("="*50)
print(f"Total cleaning time: {simulator.time:.1f} sec")
print(f"Coverage rate: {simulator.get_progress()*100:.1f}%")
print(f"Robot completion status:")
for rid in range(NUM_ROBOTS):
    cleaned_by_robot = sum(1 for b in blocks if b['cleaned'] and b['assigned_robot'] == rid)
    if cleaned_by_robot > 0:
        print(f"  Robot {rid+1}: Cleaned {cleaned_by_robot} blocks")

# ================== 7. 性能指标可视化 ==================
fig2, axes = plt.subplots(1, 2, figsize=(12, 5))

robot_cleaned_counts = [sum(1 for b in blocks if b['cleaned'] and b['assigned_robot'] == rid) 
                        for rid in range(NUM_ROBOTS)]
axes[0].bar(range(1, NUM_ROBOTS+1), robot_cleaned_counts, color='steelblue', edgecolor='black')
axes[0].set_xlabel("Robot ID")
axes[0].set_ylabel("Number of Cleaned Blocks")
axes[0].set_title("Cleaning Load Distribution")
axes[0].axhline(y=np.mean(robot_cleaned_counts), color='red', linestyle='--', 
                label=f"Average: {np.mean(robot_cleaned_counts):.1f}")
axes[0].legend()

robot_times = [sum(b['clean_time'] for b in blocks if b['assigned_robot'] == rid) 
               for rid in range(NUM_ROBOTS)]
axes[1].bar(range(1, NUM_ROBOTS+1), robot_times, color='coral', edgecolor='black')
axes[1].set_xlabel("Robot ID")
axes[1].set_ylabel("Estimated Time (sec)")
axes[1].set_title("Estimated Work Time Distribution")
axes[1].axhline(y=np.mean(robot_times), color='blue', linestyle='--', 
                label=f"Average: {np.mean(robot_times):.1f}s")
axes[1].legend()

plt.tight_layout()
plt.show()

print(f"\nLoad balance (std/mean): {np.std(robot_times)/np.mean(robot_times):.3f}")