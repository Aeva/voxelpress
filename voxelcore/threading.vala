

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
				foo.set_priority(ThreadPriority.HIGH); // make it count!
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
			unowned Thread<void*> current_thread = Thread.self<void*>();
			mutex.lock();
			mutex.unlock();
			
			while (true) {
				var wait = TimeVal();
				wait.add(1000);
				SomeType? datum = vector_queue.timed_pop(ref wait);
				//current_thread.set_priority(ThreadPriority.HIGH);
				if (datum == null) {
					// queue was empty
					if (dry_up) {
						break;
					}
					else {
						//current_thread.set_priority(ThreadPriority.LOW);
						//stdout.printf("thread stalled\n");
						Thread.yield();
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