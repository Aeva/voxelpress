

namespace voxelcore {
	private class ThreadTracker {
		private unowned Thread<void*> thread;
		public ThreadTracker(Thread<void*> t) {
			thread = t;
		}
		public void join() {
			thread.join();
		}
	}
	
	public class WorkerPool<SomeType> {
		private Mutex mutex = new Mutex();
		private AsyncQueue<SomeType> vector_queue = new AsyncQueue<SomeType>();
		private ThreadTracker[] pool;
		private bool running = false;
		private bool dry_up = false;
		
		public signal void event_hook ( SomeType entity );
		
		public WorkerPool(int thread_count, bool wait) {
			pool = new ThreadTracker[thread_count];
			if (wait) {
				mutex.lock();
			}
			else {
				running = true;
			}
			for (int i=0; i<thread_count; i+=1) {
				unowned Thread<void*> foo = Thread.create<void*>(run_thread, true);
				pool[i] = new ThreadTracker(foo);
			}
		}
		
		public void start() {
			if (!running) {
				running = true;
				mutex.unlock();
			}
		}
		
		public void join_all () {
			dry_up = true;
			for (int i=0; i<pool.length; i+=1) {
				pool[i].join();
			}
		}
		
		public void feed (SomeType input) {
			vector_queue.push(input);
		}
		
		public void* run_thread () {
			// Wait until start has been called:
			mutex.lock();
			mutex.unlock();
			
			while (true) {
				SomeType? datum = vector_queue.try_pop();
				if (datum == null) {
					// queue was empty
					if (dry_up) {
						break;
					}
					else {
						Thread.usleep(100);
						continue;
					}
				}
				else {
					// queue was not empty
					event_hook(datum);
				}
				Thread.yield();
			}
			return null;
		}
	}
}